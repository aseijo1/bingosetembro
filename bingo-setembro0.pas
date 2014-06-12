program bingosetembro0;
{Xov 12 Xuñ 2014 17:43:41 CEST  }
{proba para xestionar a concurrencia}

Const
     MaxNum= 12;{bolas carton}
     MaxJugadores= 2;
     MaxBolasCarton= 2;
     MaxCartones= 1;
     PrecioCarton = 10;
     MaxDinero = 40;   
Type 
    TCarton = array [1 .. MaxNum] of Boolean;
    TCartones= array [1 .. MaxCartones] of TCarton;
    TAciertos = array[1..MaxCartones] of integer;
    TPanel = array [1.. MaxNum] of integer;
    TMonedero= array [1.. MaxJugadores] of integer;
Var
   numero, Recaudacion, Contador: integer;
   Fin, HayDinero, empezar: boolean;
   Panel : TPanel;
   CartonPresentador: TCarton;

procedure BuscarNumero (carton: TCarton; n: integer; var encontrado: boolean);
begin
   encontrado:= (carton[n]=true);
end;

monitor bingo;

export entraPresentador, entraJugador, saleJugador, 
	   salePresentador{, imprimeJugador, imprimePresentador;
	   actMonedero};
		
var 
   pres, impr, jug	    : condition;
   presentando, imprimiendo : boolean;
   nj			    : integer;
   Monedero		    : TMonedero;
	
procedure msg(n: integer);
begin
	write(n, ' _ ');
end;

procedure ActPresentador (var carton: TCarton; var p: TPanel; n, contador: integer);
begin
  carton[n]:= true;
  p[contador]:= n;
end;

procedure EntraPresentador;
var encontrado: boolean;
begin
	if (nj<>0) or presentando or fin then delay(pres);
	encontrado:= false;
	presentando:= true;
	empezar := false;
	numero:= 1 + random(MaxNum-1);
	msg(numero);
	BuscarNumero (CartonPresentador, numero, encontrado);
	while encontrado do 
		begin
			numero := 1 + random(MaxNum-1);
			msg(numero);
			BuscarNumero (CartonPresentador, numero, encontrado);
		end;
	contador:= contador+1;
	ActPresentador (cartonPresentador, panel, numero, contador);
	sleep(1);
end;

procedure salePresentador;

begin
	presentando:= false;
	if not empty(jug) then resume(jug)
		else resume (pres);
end;

procedure entraJugador(id: integer; var ultimapos: integer; var numero: integer);
begin
	if presentando or not empty(pres) or empezar then delay(jug);
	nj := nj + 1;
	{numero:= panel[ultimapos];}
	resume(jug);
end;

procedure saleJugador(id: integer);
var k,a: integer;
begin
	nj:= nj-1;
	{a:= 0;
	if fin then begin
		for k:= 1 to MaxJugadores do 
			if (monedero[k]>=PrecioCarton) then a:= a+1; 
		fin:= false;
		while not empty(jug) do resume(jug);
		empezar:= true;
		HayDinero := (a>=2);
	end;}
	if (nj=0) then resume(pres);
end;

begin 
	presentando:= false;  nj:= 0; contador:= 0;
	{IniciaCarton(cartonPresentador);
	IniciaPanel(Panel);}
end;

process p;
begin
	repeat
		bingo.entraPresentador;
		{bingo.ImprimePresentador(panel);}
		bingo.salePresentador;	
	until not HayDinero;
end;

process type j(id: integer);
var 	
	cartones: TCartones;
	aciertos: TAciertos;
	numcart, dinero, i, ultimapos, n: integer;
	
begin
	dinero:= MaxDinero;
	ultimapos:= 1;
	bingo.entraJugador(id, ultimapos, n);
	{for i:= 1 to MaxCartones do aciertos[i]:= 0;
	GenCartones(numcart, cartones, dinero);
	bingo.actMonedero(id, dinero);
	recaudacion := recaudacion + numcart*PrecioCarton;
	repeat
		if numcart>0 then begin
			bingo.entraJugador(id, ultimapos, n);
			CompruebaCartones(Cartones, n, numcart, ultimapos, aciertos, fin);
			bingo.imprimeJugador(id, numero, numcart, ultimapos, aciertos, Cartones, fin);
			bingo.ImprimeJugador (id, numcart, aciertos, cartones);
			if fin then begin
				ultimapos:= 1; contador:= 0;
				for i:= 1 to MaxCartones do aciertos[i]:= 0;
				IniciaCarton(cartonPresentador);
				IniciaPanel(Panel);
				GenCartones(numcart, cartones, dinero);
				recaudacion := recaudacion + numcart*PrecioCarton;
				bingo.actMonedero(id, dinero);
			end;
			bingo.saleJugador(id);
		end;
	until not HayDinero;}
	bingo.saleJugador(id);
end;

var
	jug: array [1..MaxJugadores] of j;
	k: integer;
begin
	fin:= false; HayDinero:= true; Recaudacion:= 0;
	for k:= 1 to MaxNum do panel[k]:= 0;
	cobegin
		p;
		for k:= 1 to MaxJugadores do jug[k](k);
	coend;
	writeln(' Fin probas setembro ');
end.

