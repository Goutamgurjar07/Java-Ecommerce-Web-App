package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ecommerce.model.Order;
import com.ecommerce.model.Product;
import com.ecommerce.util.DBConnection;

public class AdminDAO {

    private Connection conn;

    public AdminDAO() {
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

    // 1. Total Delivered / Active Revenue
    public double getTotalRevenue() {
        double revenue = 0.0;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE LOWER(status) != 'cancelled'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                revenue = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return revenue;
    }

    // 2. Total Orders Count
    public int getTotalOrdersCount() {
        int count = 0;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT COUNT(*) FROM orders";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 3. Total Registered Customers Count
    public int getTotalUsersCount() {
        int count = 0;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT COUNT(*) FROM users WHERE LOWER(role) != 'admin'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 4. Low-Stock Alerts (Stock <= 5)
    public List<Product> getLowStockProducts(int threshold) {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM products WHERE stock <= ? ORDER BY stock ASC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, threshold);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setCategory(rs.getString("category"));
                p.setPrice(rs.getDouble("price"));
                p.setStock(rs.getInt("stock"));
                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e) {
                    p.setImageName("default.png");
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Top-Selling Products (Aggregated from Orders)
    public List<Map<String, Object>> getTopSellingProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT product_name, COUNT(*) AS total_sold, SUM(total_amount) AS total_sales " +
                         "FROM orders WHERE LOWER(status) != 'cancelled' " +
                         "GROUP BY product_name ORDER BY total_sold DESC LIMIT ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("product_name"));
                map.put("sold", rs.getInt("total_sold"));
                map.put("sales", rs.getDouble("total_sales"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Recent 5 Orders Quick Preview
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM orders ORDER BY order_id DESC LIMIT ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setOrderId(rs.getInt("order_id"));
                o.setCustomerName(rs.getString("customer_name"));
                o.setProductName(rs.getString("product_name"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("status"));
                o.setPaymentType(rs.getString("payment_type"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}