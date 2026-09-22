package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Wishlist;
import com.ecommerce.util.DBConnection;

public class WishlistDAO {

    private Connection conn;

    public WishlistDAO() {
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

    // 1. Add Product to Wishlist (Prevents duplicates)
    public boolean addToWishlist(int userId, int productId) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "INSERT IGNORE INTO wishlist (user_id, product_id) VALUES (?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, productId);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 2. Check if Product is already in Wishlist
    public boolean checkWishlist(int userId, int productId) {
        boolean exists = false;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT wishlist_id FROM wishlist WHERE user_id = ? AND product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                exists = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }

    // 3. Fetch Wishlist Items with Joined Product Details
    public List<Wishlist> getWishlistByUserId(int userId) {
        List<Wishlist> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT w.wishlist_id, w.user_id, w.product_id, w.created_at, " +
                         "p.name, p.category, p.price, p.stock, p.image_name " +
                         "FROM wishlist w " +
                         "JOIN products p ON w.product_id = p.product_id " +
                         "WHERE w.user_id = ? " +
                         "ORDER BY w.wishlist_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Wishlist w = new Wishlist();
                w.setWishlistId(rs.getInt("wishlist_id"));
                w.setUserId(rs.getInt("user_id"));
                w.setProductId(rs.getInt("product_id"));
                w.setCreatedAt(rs.getTimestamp("created_at"));
                w.setProductName(rs.getString("name"));
                w.setCategory(rs.getString("category"));
                w.setPrice(rs.getDouble("price"));
                w.setStock(rs.getInt("stock"));
                w.setImageName(rs.getString("image_name"));
                list.add(w);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Remove Single Item from Wishlist by ID
    public boolean removeWishlistItem(int wishlistId) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "DELETE FROM wishlist WHERE wishlist_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, wishlistId);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 5. Total Count of Items in Wishlist
    public int getWishlistCountByUserId(int userId) {
        int count = 0;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
}