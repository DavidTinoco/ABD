--Añade una columna LitrosVendidos a la tabla Vinos y rellénala a partir de los datos existentes. Realiza un trigger que la mantenga actualizada en cualquier caso teniendo en cuenta que los pedidos pueden sufrir modificaciones o anulaciones en las 24 horas siguientes a su realización

alter table vinos add LitrosVendidos number(38,2);
alter table pedidos add fecha date;
----------
create or replace procedure comprobarfecha(p_codpedido pedidos.fecha%type)
is
	v_fechapedido pedidos.fecha%type;
begin
	select fecha into v_fechapedido
	from pedidos
	where codpedido = p_codpedido;
	if to_char(sysdate - interval'86400'second, 'YYYYMMDDHH24MISS') < to_char(v_fechapedido,'YYYYMMDDHH24MISS') then
		raise_application_error(-20001,'No se puede modificar un pedido pasado las 24 horas');
	end if;
end;
/
----------
create or replace function sumalitros(p_codproducto productos.codproducto%type, p_numunidades lineas_de_pedido.numunidades%type)
return number
is
	v_total number;
begin
	select capacidad into v_total
	from formatos
	where codformato = (	select codformato
				from vinos_formato
				where codproducto = p_codproducto);
	v_total := v_total * p_numunidades;
	return v_total;
end;
/
----------
create or replace procedure inlitrosvendidos(p_codproducto productos.codproducto%type, p_numunidades lineas_de_pedido.numunidades%type)
is
begin
	update vinos set LitrosVendidos = (LitrosVendidos + sumalitros(p_codproducto, p_numunidades))
	where codvino = (	select codvino
				from vinos_formato
				where codproducto = p_codproducto);
end;
/
----------
create or replace procedure delitrosvendidos(p_codproducto productos.codproducto%type, p_numunidades lineas_de_pedido.numunidades%type)
is
begin
	update vinos set LitrosVendidos = (LitrosVendidos - sumalitros(p_codproducto, p_numunidades))
	where codvino = (	select codvino
				from vinos_formato
				where codproducto = p_codproducto);
end;
/
----------
create or replace trigger litrosvendidosactualizacion
after insert or update or delete on lineas_de_pedido
for each row
declare
begin
	if updating then
		comprobarfecha(:old.codpedido);
		delitrosvendidos(:old.codproducto, :old.numunidades);
		inlitrosvendidos(:new.codproducto, :new.numunidades);
	elsif inserting then
		inlitrosvendidos(:new.codproducto, :new.numunidades);
	elsif deleting then
		comprobarfecha(:old.codpedido);
		delitrosvendidos(:old.codproducto, :new.numunidades);
	end if;
end;
/

