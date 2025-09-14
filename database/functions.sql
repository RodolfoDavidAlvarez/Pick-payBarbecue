-- Function to decrement inventory when order is placed
CREATE OR REPLACE FUNCTION decrement_inventory(p_product_id UUID, p_quantity INT)
RETURNS VOID AS $$
BEGIN
    UPDATE inventory
    SET quantity_available = GREATEST(quantity_available - p_quantity, 0)
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment inventory when order is cancelled
CREATE OR REPLACE FUNCTION increment_inventory(p_product_id UUID, p_quantity INT)
RETURNS VOID AS $$
BEGIN
    UPDATE inventory
    SET quantity_available = quantity_available + p_quantity
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get available products with inventory
CREATE OR REPLACE FUNCTION get_available_products()
RETURNS TABLE (
    id UUID,
    category_id UUID,
    name VARCHAR,
    description TEXT,
    price DECIMAL,
    image_url TEXT,
    is_available BOOLEAN,
    preparation_time INT,
    quantity_available INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.category_id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.is_available,
        p.preparation_time,
        COALESCE(i.quantity_available, 0) as quantity_available
    FROM products p
    LEFT JOIN inventory i ON p.id = i.product_id
    WHERE p.is_available = true
    AND (i.quantity_available IS NULL OR i.quantity_available > 0);
END;
$$ LANGUAGE plpgsql;