USE ecommerce_IronAxis;

INSERT INTO users (email, first_name, last_name, password_hash, password_salt, role, date_of_birth) VALUES
('admin@ironaxis.com', 'Team', 'IronAxis', '$2a$10$EixVaat173H26ZZxzFi3ZexFQDPrnZFIp6X84D6MT9G9G9G9G9G9G', 'salt_admin_123', 'admin', '1995-01-01'),
('mario.rossi@gmail.com', 'Mario', 'Rossi', '$2a$10$K7SgC6QhY6X6Z6z6Z6z6ZuxFQDPrnZFIp6X84D6MT9G9G9G9G9G9G', 'salt_mario_456', 'user', '1990-05-15'),
('luca.bianchi@yahoo.it', 'Luca', 'Bianchi', '$2a$10$V8XgC6QhY6X6Z6z6Z6z6ZuxFQDPrnZFIp6X84D6MT9G9G9G9G9G9G', 'salt_luca_789', 'user', '1988-11-23');


INSERT INTO addresses (id, user_email, street, street_number, city, zip_code, province, country) VALUES
(1, 'mario.rossi@gmail.com', 'Via Roma', 12, 'Roma', '00100', 'RM', 'Italia'),
(2, 'mario.rossi@gmail.com', 'Via Milano', 88, 'Milano', '20121', 'MI', 'Italia'),
(3, 'luca.bianchi@yahoo.it', 'Corso Vittorio Emanuele II', 45, 'Torino', '10125', 'TO', 'Italia');


INSERT INTO phones (user_email, number, type) VALUES
('mario.rossi@gmail.com', '+393331234567', 'MOBILE'),
('mario.rossi@gmail.com', '06123456', 'HOME'),
('luca.bianchi@yahoo.it', '+393479876543', 'MOBILE');


INSERT INTO categories (id, name, macro_category, description) VALUES

(1, 'Proteine Siero del Latte', 'Proteine', 'Proteine a rapido assorbimento (Whey) per il recupero e la crescita muscolare.'),
(2, 'Proteine Vegetali', 'Proteine', 'Alternative plant-based ad alto valore biologico (soia, pisello, riso) per vegani.'),
(3, 'Caseine', 'Proteine', 'Proteine a lento rilascio, ideali per il pre-nanna e il recupero notturno.'),
(4, 'Barrette Proteiche', 'Proteine', 'Snack pratici e deliziosi con alto contenuto proteico per i tuoi spuntini.'),

(5, 'Pre-Workout', 'Energia & Resistenza', 'Formule potenziate per darti la massima carica esplosiva prima dell''allenamento.'),
(6, 'Intra-Workout', 'Energia & Resistenza', 'Carboidrati e sali minerali per sostenere la performance durante lo sforzo.'),
(7, 'Post-Workout', 'Energia & Resistenza', 'Miscele all-in-one per ripristinare il glicogeno e avviare il recupero immediato.'),
(8, 'Creatina', 'Energia & Resistenza', 'Il miglior integratore per l''aumento di forza, potenza e idratazione cellulare.'),
(9, 'Amminoacidi', 'Energia & Resistenza', 'BCAA ed EAA per proteggere la massa magra e ottimizzare la sintesi proteica.'),

(10, 'Vitamine e Minerali', 'Vitamine & Micronutrienti', 'Multivitaminici e minerali essenziali per il benessere quotidiano e immunitario.'),
(11, 'Acidi Grassi', 'Vitamine & Micronutrienti', 'Omega 3, 6, 9 e grassi sani per la salute cardiovascolare e articolare.'),
(12, 'Sonno e Recupero', 'Vitamine & Micronutrienti', 'Melatonina, ZMA e formule naturali per massimizzare la qualità del somno.'),

(13, 'Attrezzatura e Supporti', 'Accessori', 'Shaker, fasce, cinghie, guanti e accessori essenziali per la palestra.'),
(14, 'Abbigliamento Maschile', 'Accessori', 'T-shirt, canotte e pantaloni tecnici per massimizzare il comfort durante il workout.'),
(15, 'Abbigliamento Femminile', 'Accessori', 'Leggings, top e abbigliamento sportivo studiato per le tue sessioni di allenamento.');


INSERT INTO products (id, category_id, name, description, is_deleted) VALUES
(1, 1, 'Pure Whey Core', 'Proteine concentrate del siero del latte purissime ad alta solubilità.', false),
(2, 4, 'Iron Crunch Bar', 'Barretta proteica ipocalorica ricoperta di cioccolato croccante.', false),
(3, 8, 'Creatine Creapure XT', 'Creatina monoidrato micronizzata di qualità farmaceutica certificata.', false),
(4, 13, 'Shaker Pro Steel 700', 'Shaker in acciaio inossidabile con chiusura ermetica anti-goccia.', false);


-- Questi sono i prezzi e i dettagli attuali di catalogo (es. se domani cambiano, non rompono gli ordini vecchi)
INSERT INTO variants (id, sku, product_id, size, price, vat, quantity, flavour) VALUES
(1, 'PWC-CHOC-1KG', 1, '1000g', 34.90, 10.00, 120, 'Cioccolato'),
(2, 'PWC-VAN-1KG',  1, '1000g', 34.90, 10.00, 85,  'Vaniglia'),
(3, 'PWC-CHOC-2KG', 1, '2000g', 59.90, 10.00, 40,  'Cioccolato'),
(4, 'ICB-COOK-60G', 2, '60g',    2.99,  10.00, 500, 'Cookies & Cream'),
(5, 'CRXT-NEUT-500',3, '500g',   24.50, 22.00, 200, 'Neutro'),
(6, 'SHK-ST-BLACK', 4, '700ml',  14.90, 22.00, 50,  'Nero Opaco');


INSERT INTO reviews (user_email, product_id, score, title, comment) VALUES
('mario.rossi@gmail.com', 1, 5, 'Ottima solubilità!', 'Il gusto cioccolato è fantastico e non lascia grumi.'),
('luca.bianchi@yahoo.it', 3, 4, 'Buona creatina', 'Aumento di forza percepito dopo due settimane. Consigliata.');


INSERT INTO carts (id, user_email, total_price) VALUES
(1, 'mario.rossi@gmail.com', 37.89),
(2, 'luca.bianchi@yahoo.it', 0.00);

INSERT INTO cart_variants (cart_id, variant_id, quantity) VALUES
(1, 1, 1), -- 1x Pure Whey Cioccolato 1kg (34.90)
(1, 4, 1); -- 1x Barretta Cookies (2.99)


INSERT INTO orders (id, user_email, order_date, status, total_items, total_price, shipping_costs, 
                    shipping_street, shipping_street_number, shipping_city, shipping_zip_code, shipping_province, shipping_country) VALUES
(1, 'mario.rossi@gmail.com', '2026-03-01 10:30:00', 'SHIPPED', 2, 74.30, 4.50, 
 'Via Roma', 12, 'Roma', '00100', 'RM', 'Italia'),
 
(2, 'luca.bianchi@yahoo.it', '2026-03-05 16:15:00', 'PENDING', 3, 99.30, 0.00, 
 'Corso Vittorio Emanuele II', 45, 'Torino', '10125', 'TO', 'Italia');


INSERT INTO order_details (order_id, variant_id, quantity, purchase_price, vat, product_name, variant_sku, variant_size, variant_flavour) VALUES
(1, 1, 2, 34.90, 10.00, 'Pure Whey Core', 'PWC-CHOC-1KG', '1000g', 'Cioccolato'),
(2, 3, 1, 59.90, 10.00, 'Pure Whey Core', 'PWC-CHOC-2KG', '2000g', 'Cioccolato'),
(2, 5, 1, 24.50, 22.00, 'Creatine Creapure XT', 'CRXT-NEUT-500', '500g', 'Neutro'),
(2, 6, 1, 14.90, 22.00, 'Shaker Pro Steel 700', 'SHK-ST-BLACK', '700ml', 'Nero Opaco');


INSERT INTO payments (order_id, payment_method, last_four_digits, card_circuit, transaction_id, total_price, payment_status, payment_date) VALUES
(1, 'CREDIT_CARD', '4321', 'VISA', 'TXN-20260301-998877', 74.30, 'COMPLETED', '2026-03-01 10:32:15'),
(2, 'PAYPAL', '0000', 'PAYPAL_ACCOUNT', 'TXN-20260305-112233', 99.30, 'WAITING', '2026-03-05 16:15:00');


INSERT INTO invoices (order_id, invoice_number, holder_first_name, holder_last_name, taxable_total, total, issue_date,
                      billing_street, billing_street_number, billing_city, billing_zip_code, billing_province, billing_country) VALUES
(1, 'FT-2026-00001', 'Mario', 'Rossi', 67.55, 74.30, '2026-03-01 10:35:00',
 'Via Roma', 12, 'Roma', '00100', 'RM', 'Italia'),
 
(2, 'FT-2026-00002', 'Luca', 'Bianchi', 86.80, 99.30, '2026-03-05 16:16:00',
 'Corso Vittorio Emanuele II', 45, 'Torino', '10125', 'TO', 'Italia');