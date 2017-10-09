select sum(cantidad)
from rel_botellas_cajas_provisional
where codusuario = 'manu756';



select * from carrito_compra where codusuario = 'manu756' and codproducto in ( select codproducto from cajas);

select * from rel_botellas_cajas_provisional where codusuario = 'manu756';

select * from cajas where codproducto in ('10','11');

desc rel_botellas_cajas_provisional
