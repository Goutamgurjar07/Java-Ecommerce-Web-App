package com.ecommerce.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // 1. MySQL Driver load karein
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 2. Database Connection URL, Username & Password
            String url = "jdbc:mysql://localhost:3307/ecommerce_db?useSSL=false&allowPublicKeyRetrieval=true";
            String username = "root";
            String password = ""; // XAMPP mein default password empty hota hai

            // 3. Har baar ek naya Connection return karein
            conn = DriverManager.getConnection(url, username, password);
            // System.out.println("✅ Database Connected Successfully!");

        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL JDBC Driver Not Found!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ Database Connection Failed!");
            e.printStackTrace();
        }
        return conn;
    }

    // Direct Test Karne Ke Liye Main Method
    public static void main(String[] args) {
        Connection testConn = getConnection();
        if (testConn != null) {
            System.out.println("✅ Connection Test Passed Successfully!");
        }
    }
}