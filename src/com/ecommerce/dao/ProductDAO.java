package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Product;
import com.ecommerce.util.DBConnection;

public class ProductDAO {

    private Connection conn;

    public ProductDAO() {
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

    // 1. Add New Product
    public boolean addProduct(Product product) {
        boolean flag = false;
        try {
            Connection conn = getValidConnection();
            String sql = "INSERT INTO products (name, description, price, category, stock, image_name) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setInt(5, product.getStock());
            ps.setString(6, product.getImageName());

            int i = ps.executeUpdate();
            if (i == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flag;
    }

    // 2. Fetch All Products List
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM products ORDER BY product_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setCategory(rs.getString("category"));
                p.setStock(rs.getInt("stock"));

                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e) {
                    try { p.setImageName(rs.getString("image")); } catch (Exception ex) { p.setImageName("default.png"); }
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Single Product Fetching By product_id
    public Product getProductById(int id) {
        Product p = null;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM products WHERE product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setCategory(rs.getString("category"));
                p.setStock(rs.getInt("stock"));

                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e1) {
                    try {
                        p.setImageName(rs.getString("image"));
                    } catch (Exception e2) {
                        p.setImageName("default.png");
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error in getProductById: " + e.getMessage());
            e.printStackTrace();
        }
        return p;
    }

    // 4. Product Update By product_id
    public boolean updateProduct(Product p) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE products SET name = ?, description = ?, price = ?, category = ?, stock = ? WHERE product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, p.getName());
            ps.setString(2, p.getDescription());
            ps.setDouble(3, p.getPrice());
            ps.setString(4, p.getCategory());
            ps.setInt(5, p.getStock());
            ps.setInt(6, p.getProductId());

            int i = ps.executeUpdate();
            if (i == 1) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    // 5. Product Delete By product_id (With Cart Reference Cleanup)
    public boolean deleteProduct(int productId) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();

            // Cart table se reference remove karein taaki Foreign Key crash na ho
            try {
                String sqlCart = "DELETE FROM cart WHERE product_id = ?";
                PreparedStatement psCart = conn.prepareStatement(sqlCart);
                psCart.setInt(1, productId);
                psCart.executeUpdate();
            } catch (Exception ex) {
                // Cart table cleanup optional ignore
            }

            // Products table se delete karein
            String sql = "DELETE FROM products WHERE product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);

            int i = ps.executeUpdate();
            if (i == 1) {
                f = true;
            }
        } catch (Exception e) {
            System.out.println("❌ Error deleting product ID " + productId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return f;
    }

    // 6. Category Ke Hisab Se Products Fetch Karna
    public List<Product> getProductsByCategory(String category) {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql;
            PreparedStatement ps;

            if (category == null || category.trim().isEmpty() || "all".equalsIgnoreCase(category)) {
                sql = "SELECT * FROM products ORDER BY product_id DESC";
                ps = conn.prepareStatement(sql);
            } else {
                sql = "SELECT * FROM products WHERE LOWER(category) = LOWER(?) ORDER BY product_id DESC";
                ps = conn.prepareStatement(sql);
                ps.setString(1, category);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setCategory(rs.getString("category"));
                p.setStock(rs.getInt("stock"));

                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e) {
                    p.setImageName(rs.getString("image"));
                }

                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 7. Search Keyword Ke Hisab Se Products Fetch Karna
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT * FROM products WHERE LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?) OR LOWER(category) LIKE LOWER(?) ORDER BY product_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setCategory(rs.getString("category"));
                p.setStock(rs.getInt("stock"));

                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e) {
                    p.setImageName(rs.getString("image"));
                }

                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 8. Distinct Categories Fetch Karna (index.jsp Category Dropdown Filter ke liye)
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != '' ORDER BY category ASC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
    }

    // 9. Combined Multi-Filter Method (Keyword + Category + Max Price + Sorting)
    public List<Product> searchAndFilterProducts(String keyword, String category, Double maxPrice, String sort) {
        List<Product> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            StringBuilder sql = new StringBuilder("SELECT * FROM products WHERE 1=1 ");
            List<Object> params = new ArrayList<>();

            // Keyword Filter
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append("AND (LOWER(name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?) OR LOWER(category) LIKE LOWER(?)) ");
                String searchPattern = "%" + keyword.trim() + "%";
                params.add(searchPattern);
                params.add(searchPattern);
                params.add(searchPattern);
            }

            // Category Filter
            if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
                sql.append("AND LOWER(category) = LOWER(?) ");
                params.add(category.trim());
            }

            // Max Price Filter
            if (maxPrice != null && maxPrice > 0) {
                sql.append("AND price <= ? ");
                params.add(maxPrice);
            }

            // Sorting Options
            if ("price_asc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY price ASC");
            } else if ("price_desc".equalsIgnoreCase(sort)) {
                sql.append("ORDER BY price DESC");
            } else {
                sql.append("ORDER BY product_id DESC");
            }

            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPrice(rs.getDouble("price"));
                p.setCategory(rs.getString("category"));
                p.setStock(rs.getInt("stock"));

                try {
                    p.setImageName(rs.getString("image_name"));
                } catch (Exception e) {
                    try { p.setImageName(rs.getString("image")); } catch (Exception ex) { p.setImageName("default.png"); }
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // 10. Check if sufficient stock is available
    public boolean checkStockAvailable(int productId, int requiredQty) {
        boolean available = false;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT stock FROM products WHERE product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int currentStock = rs.getInt("stock");
                if (currentStock >= requiredQty) {
                    available = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return available;
    }

    // 11. Deduct stock upon successful order placement
    public boolean deductStock(int productId, int quantity) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            String sql = "UPDATE products SET stock = stock - ? WHERE product_id = ? AND stock >= ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            System.out.println("❌ Error deducting stock for product ID: " + productId);
            e.printStackTrace();
        }
        return f;
    }
    
}