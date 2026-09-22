package com.ecommerce.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    // Connection object single instance maintain karne ke liye
    private static Connection conn = null;
 
    public static Connection getConnection() {
        if (conn == null) {
            try {
                // 1. MySQL Driver load karein
                Class.forName("com.mysql.cj.jdbc.Driver");

                // 2. Database Connection URL, Username & Password
                // Note: Agar aapne MySQL port 3307 kar diya tha, toh below 3306 ki jagah 3307 karein
               String url = "jdbc:mysql://localhost:3307/ecommerce_db?useSSL=false&allowPublicKeyRetrieval=true";
                String username = "root";
                String password = ""; // XAMPP mein default password empty/blank hota hai

                // 3. Driver Manager se connection establish karein
                conn = DriverManager.getConnection(url, username, password);
                System.out.println("✅ Database Connected Successfully!");

            } catch (Exception e) {
                System.out.println("❌ Database Connection Failed!");
                e.printStackTrace();
            }
        }
        return conn;
    }

    // Direct Test Karne Ke Liye Main Method
    public static void main(String[] args) {
        getConnection();
    }
}