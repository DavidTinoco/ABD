--Realiza un trigger que cuando se inserte un pedido compruebe si alguna de las cajas con contenido personalizado tiene algún hueco libre, es decir, solo una parte de su capacidad total ha sido ocupada. Si es así, levantará una excepción. Esta información,obviamente, debes obtenerla del carrito de la compra

create or replace trigger cajallena
before insert on pedidos
for each row
declare
	v_capacidad number;
begin
	select capacidad into v_capacidad
	from cajas
	where codproducto in (	select codproducto
				from carrito_compra
				where codlineacarrito = :new.numlineacajcar)
