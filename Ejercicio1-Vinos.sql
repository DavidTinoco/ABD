create or replace procedure ComprobarDenominacionExiste(p_Deno vinos.denominacion%type)
is
	e_DenominacionInexistente exception;
	v_existe number;
begin
	select count(*) into v_existe
	from vinos
	where denominacion = p_Deno;
	if v_existe = 0 then
		raise e_DenominacionInexistente;
	end if;
exception
	when e_DenominacionInexistente then
		dbms_output.put_line('La denominación '||p_Deno||' no existe');
end ComprobarDenominacionExiste;
/
--------------------------------------------------------------------------------------------
create or replace procedure ComprobarProvinciaExiste(p_Prov pedidos.direnvio%type)
is
	e_ProvinciaInexistente exception;
	v_existe number;
begin
	select count(*) into v_existe
	from pedidos
	where direnvio like '%'||p_Prov||'%';
	if v_existe = 0 then
		raise e_ProvinciaInexistente;
	end if;
exception
	when e_ProvinciaInexistente then
		dbms_output.put_line('No hay datos de pedidos en la provincia '||p_Prov);
end ComprobarProvinciaExiste;
/
--------------------------------------------------------------------------------------------
create or replace function LitrosDenominacionEnProvincia(p_Deno vinos.denominacion%type, p_Prov pedidos.direnvio%type)
return number
is
	cursor c_ldep
	is
	select f.capacidad * lp.numunidades as litraje
	from formatos f, vinos_formato vf, lineas_de_pedido lp
	where f.codformato = vf.codformato
	and vf.codproducto = lp.codproducto
	and vf.codvino in (	select v.codvino
				from vinos v
				where denominacion like '%'||p_Deno||'%')
	and lp.codpedido in (	select p.codpedido
				from pedidos p
				where direnvio like '%'||p_Prov||'%');
	v_total number:=0;
	v_tempo number;
begin
	ComprobarDenominacionExiste(p_Deno);
	ComprobarProvinciaExiste(p_Prov);
	for i in c_ldep loop
		v_tempo := i.litraje;
		v_total := v_total + v_tempo;
	end loop;
	return v_total;
end;
/
