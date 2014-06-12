program bingo3;
{Mar 07 Xan 2014 21:10 CET }

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

procedure IniciaCarton (var c: TCarton);
var
   i: integer;
begin
  for i:= 1 to MaxNum do c[i]:= false;
end;

procedure IniciaPanel (var p: TPanel);
var
   i: integer;
begin
  for i:= 1 to MaxNum do p[i]:= 0;
end;

procedure BuscarNumero (carton: TCarton; n: integer; var encontrado: boolean);
begin
   encontrado:= (carton[n]=true);
end;

procedure GeneraCarton(var carton: TCarton);
var
  n, i: integer;
  ok: boolean;
begin
     ok:= false;
     IniciaCarton (carton);
     for i:= 1 to MaxBolasCarton do
     begin
          n := 1 + random(MaxNum-1);
          BuscarNumero (carton, n, ok );
          while ok do
              begin
                n := 1 + random (MaxNum - 1);
                BuscarNumero(carton, n, ok);
              end;
          Carton [n]:= true
     end;
end;

{procedure GenCartones(var nc: integer; var c: TCartones; var dinero:integer; var recaudacion: integer);}
procedure GenCartones(var nc: integer; var c: TCartones; var dinero:integer);
var
    i, k, m: integer;
begin
    nc:= 1 + random(MaxCartones-1);
    if dinero<(nc*PrecioCarton) then 
	nc:= (dinero div PrecioCarton);
    for k := 1 to nc do GeneraCarton(c[k]);
    dinero:= dinero-nc*PrecioCarton;
    {recaudacion := recaudacion + nc*PrecioCarton;}
end;

procedure ActPresentador (var carton: TCarton; var p: TPanel; n, contador: integer);

begin
  carton[n]:= true;
  p[contador]:= n;
end;

procedure CompruebaCartones(var c: TCartones; num: integer;  nc: integer; var ultima: integer; 
		var a: TAciertos; var fin: boolean);

var j: integer;
    encontrado: boolean;

begin
   for j:= 1 to nc do
     if not fin then
      begin
         BuscarNumero (c[j], num, encontrado);
 	    if encontrado then 
 	    		begin 
 	    			c[j][num]:= false;	
 	    			a[j]:= a[j]+1; 
 	    		end;
       end;
   Fin:= (a[j]=MaxBolasCarton);
   if (ultima < contador) then ultima:= ultima + 1;
end;

procedure ImprimeCarton (var carton: TCarton);
var
    i: integer;
begin
     for i:= 1 to MaxNum do if carton[i] then write (i:3);
     writeln;
end;

monitor bingo;

export entraPresentador, entraJugador, saleJugador, 
	   salePresentador, imprimeJugador, imprimePresentador;
	   actMonedero;
		
var 
	pres, impr, jug: condition;
	presentando, imprimiendo: boolean;
	nj: integer;
	Monedero: TMonedero;

procedure actMonedero(id, dinero: integer);
begin
	monedero[id]:= dinero;
end;

	
{procedure ImprimeJugador (id, numero, numcart, ultima: integer; aciertos: TAciertos; c: TCartones; fin: boolean);}
procedure ImprimeJugador (id, numcart: integer; aciertos: TAciertos; c: TCartones);
var
    i: integer;
begin
	{if imprimiendo then delay(impr);
	imprimiendo:= true;}
	{
	if fin then begin 
			writeln ('Ganador ', id, ' Carton ', numcart, ' Premio ', trunc(Recaudacion*0.9));
			Recaudacion:= 0;
		end
	else
		for i:= 1 to numcart do
			begin 
				write('Jug. ', id, ' Cart. ', i, ' n. ', numero, ' Aciertos ', aciertos[i], ' Bola ', Ultima, ' -> ');
				ImprimeCarton(c[i]);
		end;}
		
	if fin then 
		begin 
			writeln ('Ganador ', id, ' Carton ', numcart, ' Premio ', trunc(Recaudacion*0.9));
			Recaudacion:= 0;
		end;
	for i:= 1 to numcart do
	begin 
		write('Jug. ', id, ' Cart. ', i, {' n. ', numero, }' Aciertos ', aciertos[i], {' Bola ', Ultima,} ' -> ');
		ImprimeCarton(c[i]);
	end;
	
	{imprimiendo:= false;
	resume (impr);}
end;

procedure ImprimePresentador (p: TPanel);
var i: integer;
begin
	{if imprimiendo then delay(impr);
	imprimiendo := true;}
	write('Present. canta ', numero, ' Pos ', contador, ' -> ');
	for i:= 1 to MaxNum do write(p[i]:3);
	writeln;
	{imprimiendo:= false;
	resume(impr);}
end;

procedure EntraPresentador;
var encontrado: boolean;
begin
	if (nj<>0) or presentando or fin then delay(pres);
	encontrado:= false;
	presentando:= true;
	empezar := false;
	numero:= 1 + random(MaxNum-1);
	BuscarNumero (CartonPresentador, numero, encontrado);
	while encontrado do 
		begin
			numero := 1 + random(MaxNum-1);
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

{procedure entraJugador(id: integer; var ultimapos: integer; var numero: integer; nc: integer);}
procedure entraJugador(id: integer; var ultimapos: integer; var numero: integer);
begin
	if presentando or not empty(pres) or empezar then delay(jug);
	nj := nj + 1;
	numero:= panel[ultimapos];
	resume(jug);
end;

procedure saleJugador(id: integer);
var k,a: integer;
begin
	nj:= nj-1;
	a:= 0;
	if fin then begin
		for k:= 1 to MaxJugadores do 
			if (monedero[k]>=PrecioCarton) then a:= a+1; 
		fin:= false;
		while not empty(jug) do resume(jug);
		empezar:= true;
		HayDinero := (a>=2);
	end;
	if (nj=0) then resume(pres);
end;

begin 
	presentando:= false;  nj:= 0; contador:= 0;
	IniciaCarton(cartonPresentador);
	IniciaPanel(Panel);
end;

process p;

begin
	repeat
		bingo.entraPresentador;
		bingo.ImprimePresentador(panel);
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
	for i:= 1 to MaxCartones do aciertos[i]:= 0;
	{GenCartones(numcart, cartones, dinero, recaudacion);}
	GenCartones(numcart, cartones, dinero);
	bingo.actMonedero(id, dinero);
	recaudacion := recaudacion + numcart*PrecioCarton;
	{writeln(id, ' genera ', numcart,' cartones --');}
	repeat
		if numcart>0 then begin
			bingo.entraJugador(id, ultimapos, n);
			CompruebaCartones(Cartones, n, numcart, ultimapos, aciertos, fin);
			{bingo.imprimeJugador(id, numero, numcart, ultimapos, aciertos, Cartones, fin);}
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
	until not HayDinero;
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
	writeln(' Fin del Bingo ');
end.

