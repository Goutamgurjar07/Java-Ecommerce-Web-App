package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Order;
import com.ecommerce.util.DBConnection;

public class OrderDAO {

    private Connection conn;

    public OrderDAO() {
        this.conn = DBConnection.getConnection();
    }

    private Connection getValidConnection() {
        try {
            if (this.conn == null || this.conn.isClosed()) {
                this.conn = DBConnection.getConnection();
            }
        } catch (Exception e) {
            this.conn = DBConnection.getConnection();
        }
        return this.conn;
    }

    // Helper method to map ResultSet to Order object (reduces code duplication)
    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        o.setCustomerName(rs.getString("customer_name"));
        o.setEmail(rs.getString("email"));
        o.setPhone(rs.getString("phone"));
        o.setProductName(rs.getString("product_name"));
        o.setPrice(rs.getDouble("price"));
        
        try { o.setDiscountAmount(rs.getDouble("discount_amount")); } catch (Exception ex) { o.setDiscountAmount(0.0); }
        try { o.setCouponCode(rs.getString("coupon_code")); } catch (Exception ex) { o.setCouponCode(null); }
        
        o.setAddress(rs.getString("address"));
        o.setPaymentType(rs.getString("payment_type"));
        o.setTotalAmount(rs.getDouble("total_amount"));
        o.setStatus(rs.getString("status"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        return o;
    }

    // 1. Save Orders with Transaction Management & Exact Discount and Coupon Details
    public boolean saveOrders(List<Order> orderList) {
        boolean f = false;
        String sql = "INSERT INTO orders (user_id, customer_name, email, phone, product_name, price, discount_amount, coupon_code, address, payment_type, total_amount, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = getValidConnection();
        if (conn == null) return false;

        boolean originalAutoCommit = true;
        try {
            originalAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false); // Start transaction

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int successCount = 0;

                for (Order o : orderList) {
                    String custName = (o.getCustomerName() != null && !o.getCustomerName().trim().isEmpty()) ? o.getCustomerName() : "Customer";
                    String custEmail = (o.getEmail() != null && !o.getEmail().trim().isEmpty()) ? o.getEmail() : "user@eshop.com";
                    String custPhone = (o.getPhone() != null && !o.getPhone().trim().isEmpty()) ? o.getPhone() : "0000000000";
                    if (custPhone.length() > 15) custPhone = custPhone.substring(0, 15);

                    String custAddress = (o.getAddress() != null && !o.getAddress().trim().isEmpty()) ? o.getAddress() : "Delivery Address";
                    String payType = (o.getPaymentType() != null && !o.getPaymentType().trim().isEmpty()) ? o.getPaymentType() : "COD";
                    String prodName = (o.getProductName() != null) ? o.getProductName() : "Product Item";
                    String ordStatus = (o.getStatus() != null && !o.getStatus().trim().isEmpty()) ? o.getStatus() : "Placed";

                    ps.setInt(1, o.getUserId());
                    ps.setString(2, custName);
                    ps.setString(3, custEmail);
                    ps.setString(4, custPhone);
                    ps.setString(5, prodName);
                    ps.setDouble(6, o.getPrice());
                    ps.setDouble(7, o.getDiscountAmount());
                    ps.setString(8, o.getCouponCode());
                    ps.setString(9, custAddress);
                    ps.setString(10, payType);
                    ps.setDouble(11, o.getTotalAmount());
                    ps.setString(12, ordStatus);

                    ps.addBatch(); // Batch execution for better performance
                }

                int[] results = ps.executeBatch();
                for (int res : results) {
                    if (res > 0 || res == PreparedStatement.SUCCESS_NO_INFO) {
                        successCount++;
                    }
                }

                if (successCount == orderList.size()) {
                    conn.commit(); // Commit transaction if all inserts succeed
                    f = true;
                } else {
                    conn.rollback(); // Rollback if any insert failed
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(originalAutoCommit); // Restore original auto-commit state
            }

        } catch (Exception e) {
            System.out.println("❌ Database Order Save Error: " + e.getMessage());
            e.printStackTrace();
        }
        return f;
    }

    // 2. Fetch Single Order by ID (For Invoice)
    public Order getOrderById(int orderId) {
        Order o = null;
        String sql = "SELECT * FROM orders WHERE order_id = ?";
        
        try (Connection conn = getValidConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    o = extractOrderFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return o;
    }

    // 3. Fetch User Orders History
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_id DESC";
        
        try (Connection conn = getValidConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Cancel Order
    public boolean cancelOrder(int orderId, int userId) {
        boolean f = false;
        String sql = "UPDATE orders SET status = 'Cancelled' WHERE order_id = ? AND user_id = ? AND status IN ('Placed', 'Pending', 'Received')";
        
        try (Connection conn = getValidConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 5. Admin Panel Fetch All Orders
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY order_id DESC";
        
        try (Connection conn = getValidConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(extractOrderFromResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Admin Status Update
    public boolean updateOrderStatus(int orderId, String status) {
        boolean f = false;
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        
        try (Connection conn = getValidConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, orderId);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }
}