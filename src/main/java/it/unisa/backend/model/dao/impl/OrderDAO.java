package it.unisa.backend.model.dao.impl;

import it.unisa.backend.model.dao.OrderDaoInterface;
import it.unisa.backend.model.bean.*;
import it.unisa.backend.model.bean.util.OrderStatus;
import it.unisa.backend.model.bean.util.PaymentStatus;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO implements OrderDaoInterface{

    private final DataSource dataSource;

    public OrderDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public boolean save(OrderBean order){
    	
    	String queryOrder = "INSERT INTO orders (user_email, shipping_address_id, status, total_items, total_price, shipping_costs) VALUES (?, ?, ?, ?, ?, ?)";
        String queryDetails = "INSERT INTO order_details (order_id, variant_id, quantity, purchase_price, vat) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection connection = dataSource.getConnection()) {
            connection.setAutoCommit(false); 

            try (PreparedStatement psOrder = connection.prepareStatement(queryOrder, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psDetails = connection.prepareStatement(queryDetails)) {
                
                psOrder.setString(1, order.getUser().getEmail());
                psOrder.setLong(2, order.getShippingAddress().getId());
                psOrder.setString(3, order.getStatus().name());
                
                int totalItems = order.getItems().stream().mapToInt(OrderItemBean::getQuantity).sum();
                psOrder.setInt(4, totalItems);
                psOrder.setDouble(5, order.getTotalAmount());
                psOrder.setDouble(6, order.getShippingCosts());
                psOrder.executeUpdate();
                
                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) {
                        order.setId(rs.getLong(1)); 
                    } else {
                        throw new SQLException("No ID generated for this order");
                    }
                }

                if (order.getItems() != null) {
                    for (OrderItemBean item : order.getItems()) {
                        psDetails.setLong(1, order.getId()); 
                        psDetails.setLong(2, item.getVariant().getId());
                        psDetails.setInt(3, item.getQuantity());
                        psDetails.setDouble(4, item.getPriceAtPurchase()); 
                        psDetails.setDouble(5, item.getVat()); 
                        psDetails.addBatch(); 
                    }
                    psDetails.executeBatch();
                }

                if (order.getPayment() != null) {
                    savePayment(connection, order);
                }

                if (order.getInvoice() != null) {
                    saveInvoice(connection, order);
                }

                connection.commit();
                return true;

            } catch (SQLException e) {
                connection.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public OrderBean findById(Long id) {
       
        String query = "SELECT * FROM orders WHERE id = ?";
        OrderBean order = null;

        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = extractOrderFromResultSet(rs, connection);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return order;
    }

    @Override
    public List<OrderBean> findAll() {
      
        String query = "SELECT * FROM orders ORDER BY order_date DESC";
        
        List<OrderBean> orders = new ArrayList<>();
        
        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query);
             ResultSet rs = ps.executeQuery()){
        	
            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs, connection));
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    @Override
    public boolean update(OrderBean order) {
        
        String query = "UPDATE orders SET status = ? WHERE id = ?";
        
        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, order.getStatus().toString());
            ps.setLong(2, order.getId());
            
            return ps.executeUpdate() > 0;
            
        } 
        catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(Long id) {
        
        String query = "DELETE FROM orders WHERE id = ?";
        
        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setLong(1, id);
            
            return ps.executeUpdate() > 0;
            
        } 
        catch (SQLException e) {
            e.printStackTrace();
            
            return false;
        }
    }

    @Override
    public List<OrderBean> findByUserEmail(String email){
    	
        String query = "SELECT * FROM orders WHERE user_email = ? ORDER BY order_date DESC";
        
        List<OrderBean> orders = new ArrayList<>();
        
        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)){
        	
            ps.setString(1, email);
            
            try (ResultSet rs = ps.executeQuery()){
            	
                while (rs.next()) {
                    orders.add(extractOrderFromResultSet(rs, connection));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    @Override
    public List<OrderBean> findOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate){
    	
        String query = "SELECT * FROM orders WHERE order_date BETWEEN ? AND ? ORDER BY order_date DESC";
        
        List<OrderBean> orders = new ArrayList<>();
        
        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query)){
        	
            ps.setTimestamp(1, Timestamp.valueOf(startDate));
            ps.setTimestamp(2, Timestamp.valueOf(endDate));
            
            try (ResultSet rs = ps.executeQuery()){
            	
                while (rs.next()) {
                    orders.add(extractOrderFromResultSet(rs, connection));
                }
            }
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    @Override
    public List<OrderBean> findOrdersByFilters(String startDate, String endDate, String customerQuery) {
        List<OrderBean> orders = new ArrayList<>();
        
        StringBuilder query = new StringBuilder("SELECT o.* FROM orders o JOIN users u ON o.user_email = u.email WHERE 1=1");
        
        boolean hasStartDate = (startDate != null && !startDate.trim().isEmpty());
        boolean hasEndDate = (endDate != null && !endDate.trim().isEmpty());
        boolean hasCustomerFilter = (customerQuery != null && !customerQuery.trim().isEmpty());

        if (hasStartDate) {
            query.append(" AND DATE(o.order_date) >= ?");
        }
        if (hasEndDate) {
            query.append(" AND DATE(o.order_date) <= ?");
        }
        if (hasCustomerFilter) {
            query.append(" AND (o.user_email LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?)");
        }
        
        query.append(" ORDER BY o.order_date DESC");

        try (Connection connection = dataSource.getConnection();
             PreparedStatement ps = connection.prepareStatement(query.toString())) {
             
            int paramIndex = 1;
            
            if (hasStartDate) {
                ps.setString(paramIndex++, startDate);
            }
            if (hasEndDate) {
                ps.setString(paramIndex++, endDate);
            }
            if (hasCustomerFilter) {
                String searchPattern = "%" + customerQuery.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderBean order = new OrderBean();
                    order.setId(rs.getLong("id"));
                    order.setTotalAmount(rs.getDouble("total_price"));
                    
                    Timestamp ts = rs.getTimestamp("order_date");
                    if (ts != null) order.setCreatedAt(ts.toLocalDateTime());
                    
                    UserBean user = new UserBean();
                    user.setEmail(rs.getString("user_email"));
                    order.setUser(user);
                    
                    orders.add(order);
                }
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    
    private OrderBean extractOrderFromResultSet(ResultSet rs, Connection connection) throws SQLException {
        OrderBean order = new OrderBean();
        order.setId(rs.getLong("id"));
        order.setTotalAmount(rs.getDouble("total_price"));
        order.setShippingCosts(rs.getDouble("shipping_costs"));
        
        try {
            order.setStatus(OrderStatus.valueOf(rs.getString("status").toUpperCase().trim()));
        } catch (IllegalArgumentException | NullPointerException e) {
            order.setStatus(OrderStatus.PENDING); // Fallback Value
        }

        if (rs.getTimestamp("order_date") != null) {
            order.setCreatedAt(rs.getTimestamp("order_date").toLocalDateTime());
        }

        UserBean user = new UserBean();
        user.setEmail(rs.getString("user_email"));
        order.setUser(user);

        AddressBean address = findAddressById(connection, rs.getLong("shipping_address_id"));
        order.setShippingAddress(address);
        

        order.setItems(findOrderItemsByOrderId(connection, order.getId()));
		order.setPayment(findPaymentByOrderId(connection, order.getId()));
		order.setInvoice(findInvoiceByOrderId(connection, order.getId()));
        
        return order;
    }

    
    /*
     * HELPER METHODS : Retrieving information
     * */
    private List<OrderItemBean> findOrderItemsByOrderId(Connection connection, Long orderId) throws SQLException {
        String query = "SELECT od.*, v.sku, v.flavour, v.product_id " +
                       "FROM order_details od " +
                       "JOIN variants v ON od.variant_id = v.id " +
                       "WHERE od.order_id = ?";
                       
        List<OrderItemBean> items = new ArrayList<>();
        
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItemBean item = new OrderItemBean();
                    item.setOrderId(rs.getLong("order_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPriceAtPurchase(rs.getDouble("purchase_price"));
                    item.setVat(rs.getDouble("vat"));
                    
                    VariantBean variant = new VariantBean();
                    variant.setId(rs.getLong("variant_id"));
                    variant.setProductId(rs.getLong("product_id"));
                    variant.setSku(rs.getString("sku"));
                    variant.setFlavour(rs.getString("flavour"));
                    
                    item.setVariant(variant);
                    items.add(item);
                }
            }
        }
        return items;
    }
    
    private PaymentBean findPaymentByOrderId(Connection connection, Long orderId) throws SQLException {
        String query = "SELECT * FROM payments WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PaymentBean payment = new PaymentBean();
                    payment.setId(rs.getLong("id"));
                    payment.setPaymentMethod(rs.getString("payment_method"));
                    payment.setCardCircuit(rs.getString("card_circuit"));
                    payment.setLastFourDigits(rs.getString("last_four_digits"));
                    payment.setTransactionId(rs.getString("transaction_id"));
                    payment.setTotalPrice(rs.getDouble("total_price"));
                    String statusStr = rs.getString("payment_status");

                    payment.setStatus(PaymentStatus.valueOf(statusStr.toUpperCase().trim()));      
     
                    try {
                        Timestamp pDate = rs.getTimestamp("payment_date");
                        if (pDate != null && payment.getClass().getMethod("setPaymentDate", LocalDateTime.class) != null) {
                            payment.setPaymentDate(pDate.toLocalDateTime());
                        }
                    } catch (NoSuchMethodException | SecurityException e) {
                        
                    }

                    return payment;
                }
            }
        }
        return null;
    }

    private InvoiceBean findInvoiceByOrderId(Connection connection, Long orderId) throws SQLException {
        String query = "SELECT * FROM invoices WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    InvoiceBean invoice = new InvoiceBean();
                    invoice.setId(rs.getLong("id"));
                    invoice.setNumber(rs.getString("invoice_number"));
                    invoice.setHolderFirstName(rs.getString("holder_first_name"));
                    invoice.setHolderLastName(rs.getString("holder_last_name"));
                    invoice.setTaxableAmount(rs.getDouble("taxable_total"));
                    invoice.setTotalAmount(rs.getDouble("total"));
                    
                    AddressBean address = findAddressById(connection, rs.getLong("billing_address_id"));
                    invoice.setBillingAddress(address);

                    
                    try {
                        Timestamp issueDate = rs.getTimestamp("issue_date");
                        if (issueDate != null) {
                            invoice.setIssueDate(issueDate.toLocalDateTime());
                        } else {
                            invoice.setIssueDate(LocalDateTime.now());
                        }
                    } catch (SQLException e) {
                        invoice.setIssueDate(LocalDateTime.now());
                    }

                    return invoice;
                }
            }
        }
        return null;
    }
    
    private AddressBean findAddressById(Connection connection, Long id) throws SQLException {
        String query = "SELECT * FROM addresses WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AddressBean address = new AddressBean();
                    address.setId(rs.getLong("id"));
                    address.setStreet(rs.getString("street"));
                    address.setStreetNumber(rs.getInt("street_number")); 
                    address.setCity(rs.getString("city"));
                    address.setZipCode(rs.getString("zip_code"));
                    address.setProvince(rs.getString("province"));
                    address.setCountry(rs.getString("country"));
                    return address;
                }
            }
        }
        return null;
    }

    private void savePayment(Connection connection, OrderBean order) throws SQLException {
        String queryPayment = "INSERT INTO payments (order_id, payment_method, last_four_digits, card_circuit, transaction_id, total_price, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement psPayment = connection.prepareStatement(queryPayment)) {
            psPayment.setLong(1, order.getId());
            psPayment.setString(2, order.getPayment().getPaymentMethod());
            psPayment.setString(3, order.getPayment().getLastFourDigits());
            psPayment.setString(4, order.getPayment().getCardCircuit());
            psPayment.setString(5, order.getPayment().getTransactionId());
            psPayment.setDouble(6, order.getPayment().getTotalPrice());
            psPayment.setString(7, "COMPLETED"); 
            psPayment.executeUpdate();
        }
    }

    private void saveInvoice(Connection connection, OrderBean order) throws SQLException {
        String queryInvoice = "INSERT INTO invoices (order_id, invoice_number, holder_first_name, holder_last_name, billing_address_id, taxable_total, total) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement psInvoice = connection.prepareStatement(queryInvoice)) {
            psInvoice.setLong(1, order.getId());
            psInvoice.setString(2, order.getInvoice().getNumber());
            psInvoice.setString(3, order.getInvoice().getHolderFirstName());
            psInvoice.setString(4, order.getInvoice().getHolderLastName());
            psInvoice.setLong(5, order.getInvoice().getBillingAddress().getId()); 
            psInvoice.setDouble(6, order.getInvoice().getTaxableAmount());
            psInvoice.setDouble(7, order.getInvoice().getTotalAmount());
            psInvoice.executeUpdate();
        }
    }
    
}