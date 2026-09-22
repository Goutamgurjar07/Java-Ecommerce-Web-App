package com.ecommerce.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Cart;
import com.ecommerce.util.DBConnection;

public class CartDAO {

    private Connection conn;

    public CartDAO() {
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

    // 1. Add to Cart (Existing item hai toh Quantity + 1 karega, naya hai toh Insert karega)
    public boolean addToCart(Cart cart) {
        boolean flag = false;
        try {
            Connection conn = getValidConnection();
            
            // Check karein kya product pehle se cart mein maujood hai?
            String checkSql = "SELECT * FROM cart WHERE user_id = ? AND product_id = ?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, cart.getUserId());
            psCheck.setInt(2, cart.getProductId());
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                // Pehle se maujood hai -> Quantity badhayein
                int existingQty = rs.getInt("quantity");
                int newQty = existingQty + 1;
                double newTotal = cart.getPrice() * newQty;

                String updateSql = "UPDATE cart SET quantity = ?, total_price = ? WHERE cart_id = ?";
                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setInt(1, newQty);
                psUpdate.setDouble(2, newTotal);
                psUpdate.setInt(3, rs.getInt("cart_id"));

                if (psUpdate.executeUpdate() == 1) {
                    flag = true;
                }
            } else {
                // Naya item hai -> Insert karein
                String insertSql = "INSERT INTO cart (user_id, product_id, quantity, total_price) VALUES (?, ?, ?, ?)";
                PreparedStatement psInsert = conn.prepareStatement(insertSql);
                psInsert.setInt(1, cart.getUserId());
                psInsert.setInt(2, cart.getProductId());
                psInsert.setInt(3, cart.getQuantity() > 0 ? cart.getQuantity() : 1);
                psInsert.setDouble(4, cart.getTotalPrice() > 0 ? cart.getTotalPrice() : cart.getPrice());

                if (psInsert.executeUpdate() == 1) {
                    flag = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flag;
    }

    // Alias for compatibility
    public boolean addCart(Cart cart) {
        return addToCart(cart);
    }

    // 2. User ke Cart Items Fetch Karein (Products table ke saath JOIN karke)
    public List<Cart> getCartByUserId(int userId) {
        List<Cart> list = new ArrayList<>();
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT c.cart_id, c.user_id, c.product_id, c.quantity, c.total_price, " +
                         "p.name, p.price, p.image_name " +
                         "FROM cart c JOIN products p ON c.product_id = p.product_id " +
                         "WHERE c.user_id = ? ORDER BY c.cart_id DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Cart c = new Cart();
                c.setCartId(rs.getInt("cart_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setProductId(rs.getInt("product_id"));
                c.setQuantity(rs.getInt("quantity"));
                c.setTotalPrice(rs.getDouble("total_price"));
                c.setProductName(rs.getString("name"));
                c.setPrice(rs.getDouble("price"));
                c.setImageName(rs.getString("image_name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Cart Items Count Fetch Karein (Navbar Badge ke liye)
    public int getCartCountByUserId(int userId) {
        int count = 0;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT COUNT(*) FROM cart WHERE user_id = ?";
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

    // 4. Particular Item Cart se Remove Karein
    public boolean removeCartItem(int cartId) {
        boolean flag = false;
        try {
            Connection conn = getValidConnection();
            String sql = "DELETE FROM cart WHERE cart_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cartId);

            if (ps.executeUpdate() == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flag;
    }

    // 5. Order Place hone ke baad User ki Cart Clear karna
    public boolean clearCartByUserId(int userId) {
        boolean flag = false;
        try {
            Connection conn = getValidConnection();
            String sql = "DELETE FROM cart WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);

            int i = ps.executeUpdate();
            if (i >= 0) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flag;
    }

    // 6. Single Cart Item Fetch by cart_id (JOIN with products for real price & name)
    public Cart getCartById(int cartId) {
        Cart c = null;
        try {
            Connection conn = getValidConnection();
            String sql = "SELECT c.cart_id, c.user_id, c.product_id, c.quantity, c.total_price, " +
                         "p.name, p.price, p.image_name " +
                         "FROM cart c JOIN products p ON c.product_id = p.product_id " +
                         "WHERE c.cart_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cartId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                c = new Cart();
                c.setCartId(rs.getInt("cart_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setProductId(rs.getInt("product_id"));
                c.setQuantity(rs.getInt("quantity"));
                c.setTotalPrice(rs.getDouble("total_price"));
                c.setProductName(rs.getString("name"));
                c.setPrice(rs.getDouble("price"));
                c.setImageName(rs.getString("image_name"));
            }
        } catch (Exception e) {
            System.out.println("❌ Error fetching cart item by id: " + e.getMessage());
            e.printStackTrace();
        }
        return c;
    }

    // 7. Quantity & Total Price Update (Safe - Does NOT search for 'price' in cart table)
    public boolean updateQuantity(int cartId, int newQuantity, double unitPrice) {
        boolean f = false;
        try {
            Connection conn = getValidConnection();
            double newTotal = unitPrice * newQuantity;

            String sql = "UPDATE cart SET quantity = ?, total_price = ? WHERE cart_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, newQuantity);
            ps.setDouble(2, newTotal);
            ps.setInt(3, cartId);

            int i = ps.executeUpdate();
            if (i > 0) {
                f = true;
            }
        } catch (Exception e) {
            System.out.println("❌ Error updating cart quantity for cart ID: " + cartId + " - " + e.getMessage());
            e.printStackTrace();
        }
        return f;
    }

    // 8. Overloaded updateQuantity (Auto-fetches unit price via JOIN to prevent any runtime breakage)
    public boolean updateQuantity(int cartId, int newQuantity) {
        Cart cartItem = getCartById(cartId);
        double unitPrice = (cartItem != null) ? cartItem.getPrice() : 0.0;
        return updateQuantity(cartId, newQuantity, unitPrice);
    }
}