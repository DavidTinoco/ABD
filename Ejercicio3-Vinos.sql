--Realiza un trigger que cuando se inserte un pedido compruebe si alguna de las cajas con contenido personalizado tiene algún hueco libre, es decir, solo una parte de su capacidad total ha sido ocupada. Si es así, levantará una excepción. Esta información,obviamente, debes obtenerla del carrito de la compra

create or replace trigger cajallena
before insert on pedidos
for each row
declare
--Cursor que guardará cuales son las lineas de las cajas que el usuario va a comprar (se usará para la tabla que nos indica que botella va en cada caja).
	cursor c_cl
	is
	select codlineacarrito, codproducto
	from carrito_compra
	where codusuario = :new.codusuario
	and codproducto in (	select codproducto
				from cajas);
	v_capacidad number;
	v_rellenado number;
begin
	for i in c_cl loop
-- Recogemos que capacidad tiene la caja.
		select capacidad into v_capacidad
		from cajas
		where codproducto = i.codproducto;
-- Recogemos cuantas cajas se han llenado.
		select sum(cantidad) into v_rellenado
		from rel_botellas_cajas_provisional
		where codusuario = :new.codusuario
		and i.codlineacarrito = numlineacajcar;
-- Si no coincide la capacidad de la caja con las botellas que se le han asignado, saltará una excepción.
		if v_capacidad != v_rellenado then
			raise_application_error(-20001, 'Todas las cajas deben estar llenas');
		end if;
	end loop;
end;
/



















