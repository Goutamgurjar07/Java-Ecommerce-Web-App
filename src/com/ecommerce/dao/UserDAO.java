package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.ecommerce.model.User;
import com.ecommerce.util.DBConnection;

public class UserDAO {
    private Connection conn;

    public UserDAO() {
        this.conn = DBConnection.getConnection();
    }

    // Connection Re-validation Helper (Prevents connection drops in Tomcat)
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

    // 1. User Register karne ka method
    public boolean registerUser(User user) {
        boolean status = false;
        try {
            Connection conn = getValidConnection();
            String sql = "INSERT INTO users (name, email, password, phone, address, role) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole() != null ? user.getRole() : "customer");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                status = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    // 2. Duplicate Email Check (Registration Validation)
    public boolean checkEmailExist(String email) {
        boolean exists = false;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT user_id FROM users WHERE LOWER(email) = LOWER(?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                exists = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }

    // 3. User Login Verify karne ka method
    public User loginUser(String email, String password) {
        User user = null;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setPhone(rs.getString("phone"));
                user.setAddress(rs.getString("address"));
                user.setRole(rs.getString("role"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    // 4. Fetch User by user_id
    public User getUserById(int userId) {
        User user = null;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM users WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setPhone(rs.getString("phone"));
                user.setAddress(rs.getString("address"));
                user.setRole(rs.getString("role"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    // 5. User Profile & Address Update Method
    public boolean updateUserProfile(User user) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE users SET name = ?, phone = ?, address = ? WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getAddress());
            ps.setInt(4, user.getUserId());

            int i = ps.executeUpdate();
            if (i == 1) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 6. Old Password Check Karna
    public boolean checkOldPassword(int userId, String oldPassword) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT user_id FROM users WHERE user_id = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, oldPassword);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 7. Direct Password Update (Single Argument)
    public boolean changePassword(int userId, String newPassword) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE users SET password = ? WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setInt(2, userId);

            int i = ps.executeUpdate();
            if (i == 1) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 8. Secure Password Change with Old Password Verification (3 Parameters)
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        boolean f = false;
        try {
            if (checkOldPassword(userId, oldPassword)) {
                f = changePassword(userId, newPassword);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 9. Alias for checkAndChangePassword
    public boolean checkAndChangePassword(int userId, String oldPassword, String newPassword) {
        return changePassword(userId, oldPassword, newPassword);
    }
}