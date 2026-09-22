package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Review;
import com.ecommerce.util.DBConnection;

public class ReviewDAO {

    private Connection conn;

    public ReviewDAO() {
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

    // 1. Submit New Rating & Review
    public boolean addReview(Review r) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "INSERT INTO reviews (user_id, product_name, user_name, rating, review_text) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, r.getUserId());
            ps.setString(2, r.getProductName());
            ps.setString(3, r.getUserName());
            ps.setInt(4, r.getRating());
            ps.setString(5, r.getReviewText());

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 2. Fetch Reviews for a Product
    public List<Review> getReviewsByProduct(String productName) {
        List<Review> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM reviews WHERE LOWER(product_name) = LOWER(?) ORDER BY review_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, productName.trim());
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Review r = new Review();
                r.setReviewId(rs.getInt("review_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setProductName(rs.getString("product_name"));
                r.setUserName(rs.getString("user_name"));
                r.setRating(rs.getInt("rating"));
                r.setReviewText(rs.getString("review_text"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}