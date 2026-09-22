<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Wishlist" %>
<%@ page import="com.ecommerce.dao.WishlistDAO" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wishlist - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .wishlist-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .wishlist-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
        }
        .wishlist-thumb-box {
            height: 180px;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px;
        }
        .wishlist-thumb {
            max-height: 100%;
            max-width: 100%;
            object-fit: contain;
        }
    </style>
</head>
<body class="bg-light">

    <%-- Session Guard & Data Retrieval --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to view your Wishlist!");
            response.sendRedirect("login.jsp");
            return;
        }

        CartDAO cartDao = new CartDAO();
        int cartCount = cartDao.getCartCountByUserId(user.getUserId());

        WishlistDAO wishDao = new WishlistDAO();
        List<Wishlist> wishlist = wishDao.getWishlistByUserId(user.getUserId());
        int wishCount = (wishlist != null) ? wishlist.size() : 0;
    %>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top mb-4">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.jsp">🛒 E-Shop</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navBar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navBar">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link text-white fw-bold" href="myOrders.jsp">📦 My Orders</a></li>
                </ul>

                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item me-2">
                        <a href="wishlist.jsp" class="btn btn-outline-light position-relative fw-bold active">
                            ❤️ Wishlist
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning text-dark">
                                <%= wishCount %>
                            </span>
                        </a>
                    </li>
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
                           href="#" id="userDrop" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            👤 <%= user.getName() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2">
                            <li><a class="dropdown-item fw-semibold" href="profile.jsp">👤 My Profile</a></li>
                            <li><a class="dropdown-item fw-semibold" href="wishlist.jsp">❤️ My Wishlist (<%= wishCount %>)</a></li>
                            <li><a class="dropdown-item fw-semibold" href="myOrders.jsp">📦 My Orders</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item fw-semibold text-danger" href="LogoutServlet">🚪 Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Alert Messages Banner -->
    <div class="container">
        <% 
            String errorMsg = (String) session.getAttribute("failedMsg");
            String succMsg = (String) session.getAttribute("succMsg");
            if (errorMsg != null) { 
        %>
            <div class="alert alert-danger alert-dismissible fade show text-center fw-bold" role="alert">
                ❌ <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("failedMsg"); } %>
        <% if (succMsg != null) { %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("succMsg"); } %>
    </div>

    <!-- Main Content Container -->
    <div class="container my-4 mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-0">❤️ My Saved Items & Wishlist</h3>
                <small class="text-muted">Total Saved Products: <span class="badge bg-primary"><%= wishCount %></span></small>
            </div>
            <a href="index.jsp" class="btn btn-outline-primary fw-bold">← Continue Shopping</a>
        </div>

        <% if (wishlist != null && !wishlist.isEmpty()) { %>
            <div class="row g-4">
                <% 
                    for (Wishlist w : wishlist) { 
                        String img = (w.getImageName() != null && !w.getImageName().trim().isEmpty()) ? w.getImageName().trim() : "default.png";
                        boolean isOutOfStock = (w.getStock() <= 0);
                %>
                <div class="col-xl-3 col-lg-4 col-md-6 col-sm-6">
                    <div class="card h-100 wishlist-card border-0 rounded-4 shadow-sm overflow-hidden bg-white d-flex flex-column position-relative">
                        
                        <!-- Remove button on top-right -->
                        <a href="RemoveWishlistServlet?wid=<%= w.getWishlistId() %>" 
                           class="btn btn-light btn-sm rounded-circle position-absolute top-0 end-0 m-2 shadow-sm text-danger" 
                           title="Remove from Wishlist"
                           onclick="return confirm('Remove <%= w.getProductName() %> from Wishlist?');">
                            ✕
                        </a>

                        <!-- Product Image -->
                        <div class="wishlist-thumb-box border-bottom">
                            <a href="productDetails.jsp?pid=<%= w.getProductId() %>" class="w-100 h-100 d-flex align-items-center justify-content-center">
                                <img src="uploads/<%= img %>" 
                                     alt="<%= w.getProductName() %>" 
                                     class="wishlist-thumb"
                                     onerror="this.onerror=null; this.src='img/<%= img %>'; this.onerror=function(){this.src='https://via.placeholder.com/200x180?text=No+Img';};">
                            </a>
                        </div>

                        <!-- Card Body -->
                        <div class="card-body p-3 d-flex flex-column flex-grow-1">
                            <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle mb-2 align-self-start">
                                <%= w.getCategory() != null ? w.getCategory() : "General" %>
                            </span>

                            <h6 class="fw-bold text-dark text-truncate mb-2" title="<%= w.getProductName() %>">
                                <a href="productDetails.jsp?pid=<%= w.getProductId() %>" class="text-decoration-none text-dark">
                                    <%= w.getProductName() %>
                                </a>
                            </h6>

                            <div class="mt-auto d-flex justify-content-between align-items-center mb-3">
                                <span class="fs-5 fw-bold text-success">₹<%= String.format("%.2f", w.getPrice()) %></span>
                                <span class="badge <%= isOutOfStock ? "bg-danger" : "bg-success" %>">
                                    <%= isOutOfStock ? "Out of Stock" : "In Stock" %>
                                </span>
                            </div>

                            <!-- Move to Cart Action -->
                            <div class="d-grid">
                                <a href="AddToCartServlet?pid=<%= w.getProductId() %>" 
                                   class="btn btn-primary fw-bold shadow-sm <%= isOutOfStock ? "disabled" : "" %>">
                                    🛒 Move to Cart
                                </a>
                            </div>
                        </div>

                    </div>
                </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="card shadow-sm border-0 rounded-4 text-center py-5 bg-white">
                <div class="card-body py-5">
                    <div class="display-1 mb-3">🤍</div>
                    <h3 class="fw-bold text-dark mb-2">Your Wishlist is Empty!</h3>
                    <p class="text-muted mb-4">Explore our trending collection and save products you love for later.</p>
                    <a href="index.jsp" class="btn btn-primary btn-lg fw-bold px-5 rounded-pill shadow-sm">
                        🛍️ Explore Products
                    </a>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>