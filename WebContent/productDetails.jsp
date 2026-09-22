<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.model.Review" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.ReviewDAO" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .product-detail-img {
            max-height: 400px;
            width: 100%;
            object-fit: contain;
            border-radius: 12px;
            background-color: #ffffff;
            padding: 20px;
        }
        .star-gold {
            color: #ffc107;
        }
        .star-gray {
            color: #dee2e6;
        }
        .review-card {
            border-left: 4px solid #ffc107;
            transition: transform 0.2s ease;
        }
        .review-card:hover {
            transform: translateX(4px);
        }
    </style>
</head>
<body class="bg-light">

    <%-- Data Retrieval & Math Logic --%>
    <%
        User user = (User) session.getAttribute("userobj");
        int cartCount = 0;
        if (user != null) {
            CartDAO cartDao = new CartDAO();
            cartCount = cartDao.getCartCountByUserId(user.getUserId());
        }

        String pidStr = request.getParameter("pid");
        if (pidStr == null || pidStr.trim().isEmpty()) {
            pidStr = request.getParameter("id");
        }

        int productId = 0;
        Product product = null;

        if (pidStr != null && !pidStr.trim().isEmpty()) {
            try {
                productId = Integer.parseInt(pidStr.trim());
                ProductDAO pDao = new ProductDAO();
                product = pDao.getProductById(productId);
            } catch (Exception e) {
                product = null;
            }
        }

        if (product == null) {
            session.setAttribute("failedMsg", "Product not found or unavailable!");
            response.sendRedirect("index.jsp");
            return;
        }

        // Fetch Customer Reviews
        ReviewDAO reviewDao = new ReviewDAO();
        List<Review> reviewList = reviewDao.getReviewsByProduct(product.getName());

        int totalReviews = (reviewList != null) ? reviewList.size() : 0;
        double totalRatingPoints = 0.0;
        double avgRating = 0.0;

        int count5 = 0, count4 = 0, count3 = 0, count2 = 0, count1 = 0;

        if (reviewList != null && !reviewList.isEmpty()) {
            for (Review r : reviewList) {
                int score = r.getRating();
                totalRatingPoints += score;
                if (score == 5) count5++;
                else if (score == 4) count4++;
                else if (score == 3) count3++;
                else if (score == 2) count2++;
                else if (score == 1) count1++;
            }
            if (totalReviews > 0) {
                avgRating = totalRatingPoints / totalReviews;
                avgRating = Math.round(avgRating * 10.0) / 10.0;
            }
        }

        int fullStars = (int) Math.floor(avgRating);
        String imgName = (product.getImageName() != null && !product.getImageName().trim().isEmpty()) ? product.getImageName() : "default.png";
        boolean isOutOfStock = (product.getStock() <= 0);
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
                    <% if (user != null) { %>
                        <li class="nav-item"><a class="nav-link text-white fw-bold" href="myOrders.jsp">📦 My Orders</a></li>
                    <% } %>
                </ul>

                <ul class="navbar-nav ms-auto align-items-center">
                    <% if (user == null) { %>
                        <li class="nav-item me-2"><a class="btn btn-light text-primary fw-bold" href="login.jsp">Login</a></li>
                        <li class="nav-item"><a class="btn btn-outline-light fw-bold" href="register.jsp">Register</a></li>
                    <% } else { %>
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
                                <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                    <span class="badge bg-danger ms-1">Admin</span>
                                <% } %>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2">
                                <li><a class="dropdown-item fw-semibold" href="profile.jsp">👤 Profile</a></li>
                                <li><a class="dropdown-item fw-semibold" href="myOrders.jsp">📦 Orders</a></li>
                                <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item fw-semibold text-warning" href="adminDashboard.jsp">⚙️ Admin Dashboard</a></li>
                                <% } %>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-semibold text-danger" href="LogoutServlet">🚪 Logout</a></li>
                            </ul>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container mb-5">
        
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="index.jsp" class="text-decoration-none">Home</a></li>
                <li class="breadcrumb-item"><a href="index.jsp?category=<%= product.getCategory() %>" class="text-decoration-none"><%= product.getCategory() %></a></li>
                <li class="breadcrumb-item active" aria-current="page"><%= product.getName() %></li>
            </ol>
        </nav>

        <!-- Product Hero Section -->
        <div class="card shadow-sm border-0 rounded-4 overflow-hidden mb-5">
            <div class="row g-0">
                
                <!-- Product Image -->
                <div class="col-lg-5 p-4 d-flex align-items-center justify-content-center bg-white border-end">
                    <img src="uploads/<%= imgName %>" 
                         alt="<%= product.getName() %>" 
                         class="product-detail-img"
                         onerror="this.onerror=null; this.src='img/<%= imgName %>'; this.onerror=function(){this.src='https://via.placeholder.com/350x350?text=No+Image';};">
                </div>

                <!-- Product Purchase Info -->
                <div class="col-lg-7 p-4 p-md-5 d-flex flex-column justify-content-between bg-white">
                    <div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 fs-6">
                                🏷️ <%= product.getCategory() %>
                            </span>
                            <span class="badge <%= isOutOfStock ? "bg-danger" : "bg-success" %> px-3 py-2 fs-6">
                                <%= isOutOfStock ? "Out of Stock" : "In Stock (" + product.getStock() + " available)" %>
                            </span>
                        </div>

                        <h2 class="fw-bold text-dark mb-3"><%= product.getName() %></h2>

                        <!-- ⭐ Dynamic Star Rating Header -->
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <div class="fs-5">
                                <% 
                                    for (int i = 1; i <= 5; i++) {
                                        if (i <= fullStars) { 
                                %>
                                    <span class="star-gold">★</span>
                                <%      } else { %>
                                    <span class="star-gray">★</span>
                                <%      } 
                                    } 
                                %>
                            </div>
                            <span class="fw-bold fs-5 text-dark"><%= avgRating > 0 ? avgRating : "No ratings yet" %></span>
                            <span class="text-muted small">(<%= totalReviews %> Customer <%= totalReviews == 1 ? "Review" : "Reviews" %>)</span>
                        </div>

                        <div class="mb-4">
                            <span class="text-muted fs-5">Special Price:</span>
                            <div class="display-6 fw-bold text-success">₹<%= String.format("%.2f", product.getPrice()) %></div>
                            <small class="text-muted">Inclusive of all taxes • Free Express Delivery</small>
                        </div>

                        <h6 class="fw-bold text-dark mb-2">Product Description:</h6>
                        <p class="text-muted lh-base mb-4">
                            <%= product.getDescription() != null ? product.getDescription() : "No detailed description provided for this product." %>
                        </p>
                    </div>

                    <!-- Action Buttons -->
                    <div class="d-flex gap-3 pt-3 border-top">
                        <a href="AddToCartServlet?pid=<%= product.getProductId() %>" 
                           class="btn btn-primary btn-lg flex-grow-1 fw-bold py-3 shadow-sm <%= isOutOfStock ? "disabled" : "" %>">
                            🛒 Add to Cart
                        </a>
                        <a href="index.jsp" class="btn btn-outline-secondary btn-lg fw-bold px-4">
                            ← Back
                        </a>
                    </div>
                </div>

            </div>
        </div>

        <!-- Customer Reviews & Rating Breakdown Section -->
        <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white">
            <h3 class="fw-bold text-dark mb-4">⭐ Customer Ratings & Reviews</h3>

            <div class="row g-4 mb-4 pb-4 border-bottom align-items-center">
                
                <!-- Average Score Box -->
                <div class="col-md-4 text-center border-end">
                    <div class="display-3 fw-bold text-warning mb-0"><%= avgRating > 0 ? avgRating : "0.0" %></div>
                    <div class="fs-4 mb-2">
                        <% 
                            for (int i = 1; i <= 5; i++) {
                                if (i <= fullStars) { 
                        %>
                            <span class="star-gold">★</span>
                        <%      } else { %>
                            <span class="star-gray">★</span>
                        <%      } 
                            } 
                        %>
                    </div>
                    <div class="text-muted fw-semibold">Based on <%= totalReviews %> reviews</div>
                </div>

                <!-- Star Rating Distribution Bars -->
                <div class="col-md-8">
                    <% 
                        int[] counts = { count5, count4, count3, count2, count1 };
                        for (int star = 5; star >= 1; star--) {
                            int cnt = counts[5 - star];
                            int pct = (totalReviews > 0) ? (int) Math.round(((double) cnt * 100.0) / totalReviews) : 0;
                    %>
                        <div class="d-flex align-items-center gap-3 mb-2">
                            <span class="fw-semibold text-muted" style="width: 55px;"><%= star %> Stars</span>
                            <div class="progress flex-grow-1" style="height: 10px;">
                                <div class="progress-bar bg-warning" role="progressbar" style="--bs-progress-bar-width: <%= pct %>%; width: 0;" aria-valuenow="<%= pct %>" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <span class="text-muted small" style="width: 40px; text-align: right;"><%= cnt %></span>
                        </div>
                    <% } %>
                </div>

            </div>

            <!-- List of Individual Reviews -->
            <div class="mt-4">
                <h5 class="fw-bold text-dark mb-3">User Feedback (<%= totalReviews %>)</h5>

                <% if (reviewList != null && !reviewList.isEmpty()) { 
                    for (Review rev : reviewList) {
                        String revDate = "";
                        if (rev.getCreatedAt() != null) {
                            String s = rev.getCreatedAt().toString();
                            revDate = s.length() >= 10 ? s.substring(0, 10) : s;
                        }
                %>
                    <div class="card review-card bg-light border-0 rounded-3 p-3 mb-3 shadow-sm">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div>
                                <span class="fw-bold text-dark fs-6">👤 <%= rev.getUserName() != null ? rev.getUserName() : "Customer" %></span>
                                <span class="badge bg-success-subtle text-success border border-success-subtle ms-2">Verified Buyer</span>
                            </div>
                            <small class="text-muted"><%= revDate %></small>
                        </div>

                        <!-- Star Rating for this review -->
                        <div class="mb-2">
                            <% for (int s = 1; s <= 5; s++) { 
                                if (s <= rev.getRating()) { %>
                                    <span class="star-gold fs-6">★</span>
                            <%  } else { %>
                                    <span class="star-gray fs-6">★</span>
                            <%  } 
                            } %>
                        </div>

                        <p class="text-dark mb-0 lh-base">
                            <%= rev.getReviewText() != null ? rev.getReviewText() : "" %>
                        </p>
                    </div>
                <% 
                    }
                } else { 
                %>
                    <div class="text-center py-4 bg-light rounded-4">
                        <h5 class="text-muted fw-bold mb-1">No reviews yet!</h5>
                        <p class="text-muted small mb-0">Be the first to order and leave a verified review for this product.</p>
                    </div>
                <% } %>
            </div>

        </div>

    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>