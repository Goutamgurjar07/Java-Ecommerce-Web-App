<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile & Security - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <%-- Session Guard --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to access profile!");
            response.sendRedirect("login.jsp");
            return;
        }

        CartDAO cartDao = new CartDAO();
        int cartCount = cartDao.getCartCountByUserId(user.getUserId());
    %>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.jsp">🛒 E-Shop</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="myOrders.jsp">📦 My Orders</a></li>
                </ul>

                <!-- Profile Dropdown Navbar -->
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-3">
                        <a href="cart.jsp" class="btn btn-light text-primary position-relative fw-bold">
                            🛒 Cart
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                <%= cartCount %>
                            </span>
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle text-warning fw-bold btn btn-outline-light text-warning px-3 py-1 border-warning rounded-pill" 
                           href="#" id="userMenuDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            👤 Welcome, <%= user.getName() %>
                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                <span class="badge bg-danger ms-1">Admin</span>
                            <% } %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2" aria-labelledby="userMenuDropdown">
                            <li class="px-3 py-2 bg-light border-bottom rounded-top">
                                <div class="fw-bold text-dark"><%= user.getName() %></div>
                                <small class="text-muted"><%= user.getEmail() %></small>
                            </li>
                            <li><a class="dropdown-item fw-semibold py-2" href="profile.jsp">👤 My Profile & Security</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="myOrders.jsp">📦 My Orders</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="cart.jsp">🛒 View Cart (<%= cartCount %>)</a></li>
                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-semibold text-warning py-2" href="adminDashboard.jsp">⚙️ Admin Dashboard</a></li>
                            <% } %>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item fw-semibold text-danger py-2" href="LogoutServlet">🚪 Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Alert Messages Banner -->
    <div class="container mt-2">
        <% 
            String errorMsg = (String) session.getAttribute("failedMsg");
            String succMsg = (String) session.getAttribute("succMsg");
            if (errorMsg != null) { 
        %>
            <div class="alert alert-danger alert-dismissible fade show text-center fw-bold" role="alert">
                ❌ <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% 
                session.removeAttribute("failedMsg");
            } 
            if (succMsg != null) { 
        %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                ✅ <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% 
                session.removeAttribute("succMsg");
            } 
        %>
    </div>

    <!-- Main Profile & Security Container -->
    <div class="container my-4 mb-5">
        <div class="row g-4">
            
            <!-- Left Card: Personal Details & Delivery Address Form -->
            <div class="col-lg-7">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h4 class="fw-bold text-primary mb-0">👤 Edit Personal Details & Address</h4>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Saved Profile</span>
                    </div>
                    <div class="card-body p-4">
                        <form action="UpdateUserServlet" method="post">
                            <input type="hidden" name="action" value="updateProfile">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Full Name</label>
                                    <input type="text" class="form-control" name="name" value="<%= user.getName() != null ? user.getName() : "" %>" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email Address</label>
                                    <input type="email" class="form-control" name="email" value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Phone Number</label>
                                    <input type="tel" class="form-control" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" placeholder="10-digit mobile number" required>
                                </div>

                                <!-- Delivery Address Input Field -->
                                <div class="col-12">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <label class="form-label fw-semibold mb-0">Default Delivery Address</label>
                                        <small class="text-muted">Auto-fills during checkout</small>
                                    </div>
                                    <textarea class="form-control" name="address" rows="3" placeholder="House No., Building, Street Name, Area, City, State - Pincode" required><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                                </div>

                                <div class="col-12 mt-4">
                                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold shadow-sm">
                                        💾 Save Profile & Address Changes
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Card: Change Password Form -->
            <div class="col-lg-5">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-header bg-white py-3 border-bottom">
                        <h4 class="fw-bold text-danger mb-0">🔒 Security & Password</h4>
                    </div>
                    <div class="card-body p-4">
                        <form action="UpdateUserServlet" method="post">
                            <input type="hidden" name="action" value="changePassword">

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Current (Old) Password</label>
                                <input type="password" class="form-control" name="oldPassword" placeholder="Enter current password" required>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-semibold">New Password</label>
                                <input type="password" class="form-control" name="newPassword" placeholder="Enter new password" minlength="4" required>
                            </div>

                            <button type="submit" class="btn btn-danger btn-lg w-100 fw-bold shadow-sm">
                                🔑 Update Password
                            </button>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>