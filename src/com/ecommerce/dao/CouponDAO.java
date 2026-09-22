package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.ecommerce.model.Coupon;
import com.ecommerce.util.DBConnection;

public class CouponDAO {

    private Connection conn;

    public CouponDAO() {
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

    // Case-Insensitive Coupon Fetch
    public Coupon getCouponByCode(String code) {
        Coupon c = null;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM coupons WHERE UPPER(TRIM(coupon_code)) = UPPER(TRIM(?)) AND (LOWER(status) = 'active' OR status IS NULL)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, code.trim());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                c = new Coupon();
                c.setCouponId(rs.getInt("coupon_id"));
                c.setCouponCode(rs.getString("coupon_code"));
                c.setDiscountType(rs.getString("discount_type"));
                c.setDiscountValue(rs.getDouble("discount_value"));
                c.setMinOrderAmount(rs.getDouble("min_order_amount"));
                c.setStatus(rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return c;
    }
}