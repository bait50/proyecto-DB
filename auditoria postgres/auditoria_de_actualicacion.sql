CREATE TABLE IF NOT EXISTS public.auditoria_productos
(  id SERIAL Primary key,
   idProd INT NOT NULL,  -- guardar el id del usuario que se afecto
   operacion VARCHAR(10) NOT NULL, -- UPDATE, DELETE, INSERT
   fecha TIMESTAMP DEFAULT now(),
   datos JSONB 
);

CREATE OR REPLACE FUNCTION auditar_productos()
RETURNS TRIGGER 
AS
$$
BEGIN
	IF(OLD.precio IS DISTINCT FROM NEW.precio) THEN
		INSERT INTO public.auditoria_productos (idProd, operacion, datos)
		VALUES (NEW."idProd",'UPDATE', row_to_json('old',row_to_json(OLD.precio),'new',row_to_json(NEW.precio)));
	ELSIF(OLD.stock IS DISTINCT FROM NEW.stock) THEN
		INSERT INTO public.auditoria_productos (idProd, operacion, datos)
		VALUES (NEW."idProd",'UPDATE', row_to_json('old',row_to_json(OLD.stock),'new',row_to_json(NEW.stock)));
	END IF;
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trigger_auditar_productos
AFTER UPDATE ON public.productos
FOR EACH ROW
EXECUTE FUNCTION auditar_productos();