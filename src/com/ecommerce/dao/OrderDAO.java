package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

    // 1. Save Orders with Exact Discount and Coupon Details
    public boolean saveOrders(List<Order> orderList) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "INSERT INTO orders (user_id, customer_name, email, phone, product_name, price, discount_amount, coupon_code, address, payment_type, total_amount, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
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

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    successCount++;
                }
            }

            if (successCount > 0) {
                f = true;
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
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM orders WHERE order_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                o = new Order();
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return o;
    }

    // 3. Fetch User Orders History
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
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
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Cancel Order
    public boolean cancelOrder(int orderId, int userId) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE orders SET status = 'Cancelled' WHERE order_id = ? AND user_id = ? AND status IN ('Placed', 'Pending', 'Received')";
            PreparedStatement ps = conn.prepareStatement(sql);
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
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM orders ORDER BY order_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
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
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Admin Status Update
    public boolean updateOrderStatus(int orderId, String status) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
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