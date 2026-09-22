# 🛒 E-Shop - Full Stack Java E-Commerce Web Application

A dynamic, fully functional E-Commerce web application built using **Java Servlets**, **JSP**, **JDBC**, **MySQL**, and **Bootstrap 5**.

---

## ✨ Features
- 👤 **User Authentication**: Registration, Login, Logout, and Session Security.
- 🛍️ **Product Browsing**: Dynamic categories, live AJAX search suggestions, and sorting (price high/low, newest).
- 🛒 **Shopping Cart & Wishlist**: Real-time count badges, add/remove items.
- 📦 **Order Management**: Checkout flow, order status tracking (Placed, Shipped, Delivered).
- ⚙️ **Admin Dashboard**: Manage products (Add/Edit/Delete), update order status, and view application stats.

---

## 🛠️ Tech Stack
- **Backend**: Java 22, Servlets (Jakarta EE / Tomcat 10), JDBC
- **Frontend**: JSP, HTML5, CSS3, JavaScript (AJAX), Bootstrap 5
- **Database**: MySQL Server
- **Server**: Apache Tomcat 10+

---

## 🚀 How to Run Locally

### Prerequisites
1. JDK 17 or higher
2. Apache Tomcat 10+
3. MySQL Database Server

### Setup Database
1. Import the SQL file or create tables for `users`, `products`, `cart`, `wishlist`, and `orders`.
2. Update database credentials in `DBConnect.java` / `ProductDAO.java`.

### Build & Deploy
1. Compile Java files into `WebContent/WEB-INF/classes`.
2. Deploy the `WebContent` directory to Tomcat's `webapps` folder.
3. Access at `http://localhost:8080/MyEcommerceApp/index.jsp`.