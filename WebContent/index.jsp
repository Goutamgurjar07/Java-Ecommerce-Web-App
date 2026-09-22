<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Shop - Best Online Deals</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .product-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.12) !important;
        }
        .product-img-container {
            height: 220px;
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
        }
        .product-img {
            max-height: 100%;
            max-width: 100%;
            object-fit: contain;
        }
    </style>
</head>
<body class="bg-light">

    <%-- Session Fetch & Filter Logic --%>
    <%
        User user = (User) session.getAttribute("userobj");
        int cartCount = 0;
        if (user != null) {
            CartDAO cartDao = new CartDAO();
            cartCount = cartDao.getCartCountByUserId(user.getUserId());
        }

        // Request parameters
        String searchQuery = request.getParameter("search");
        if (searchQuery == null) {
            searchQuery = request.getParameter("ch");
        }

        String selectedCategory = request.getParameter("category");
        if (selectedCategory == null || selectedCategory.trim().isEmpty()) {
            selectedCategory = "all";
        }

        String maxPriceParam = request.getParameter("maxPrice");
        Double maxPrice = null;
        if (maxPriceParam != null && !maxPriceParam.trim().isEmpty()) {
            try {
                maxPrice = Double.parseDouble(maxPriceParam.trim());
            } catch (Exception e) {
                maxPrice = null;
            }
        }

        String sortBy = request.getParameter("sort");

        ProductDAO productDao = new ProductDAO();
        List<Product> productList = productDao.searchAndFilterProducts(searchQuery, selectedCategory, maxPrice, sortBy);
        List<String> dbCategories = productDao.getAllCategories();
    %>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.jsp">🛒 E-Shop</a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active fw-bold" href="index.jsp">Home</a>
                    </li>
                    
                    <% if (user != null) { %>
                        <li class="nav-item">
                            <a class="nav-link text-white fw-bold" href="myOrders.jsp">📦 My Orders</a>
                        </li>
                    <% } %>

                    <%-- Admin Controls Dropdown --%>
                    <% if (user != null && "admin".equalsIgnoreCase(user.getRole())) { %>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle text-warning fw-bold" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                ⚙️ Admin Controls
                            </a>
                            <ul class="dropdown-menu shadow border-0 rounded-3">
                                <li><a class="dropdown-item fw-semibold text-primary" href="adminDashboard.jsp">📊 Admin Dashboard</a></li>
                                <li><a class="dropdown-item fw-semibold" href="adminProducts.jsp">📦 Manage Products</a></li>
                                <li><a class="dropdown-item fw-semibold" href="addProduct.jsp">➕ Add New Product</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item fw-semibold text-success" href="adminOrders.jsp">📋 Manage Orders & Status</a></li>
                            </ul>
                        </li>
                    <% } %>
                </ul>

                <!-- 🔍 Search Bar in Navbar -->
                <form class="d-flex mx-auto me-lg-3 my-2 my-lg-0" action="index.jsp" method="get" style="max-width: 320px; width: 100%;">
                    <% if (selectedCategory != null && !"all".equalsIgnoreCase(selectedCategory)) { %>
                        <input type="hidden" name="category" value="<%= selectedCategory %>">
                    <% } %>
                    <input class="form-control me-1 rounded-pill ps-3" type="search" name="search" placeholder="Search products..." value="<%= searchQuery != null ? searchQuery : "" %>">
                    <button class="btn btn-warning rounded-pill px-3 fw-bold" type="submit">🔍</button>
                </form>

                <!-- Auth & User Profile Dropdown -->
                <ul class="navbar-nav ms-auto align-items-center">
                    <% if (user == null) { %>
                        <li class="nav-item me-2">
                            <a class="btn btn-light text-primary fw-bold" href="login.jsp">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="btn btn-outline-light fw-bold" href="register.jsp">Register</a>
                        </li>
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
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Alert Messages Banner -->
    <div class="container mt-3">
        <% 
            String errorMsg = (String) session.getAttribute("failedMsg");
            String succMsg = (String) session.getAttribute("succMsg");
            if (errorMsg != null) { 
        %>
            <div class="alert alert-danger alert-dismissible fade show text-center fw-bold" role="alert">
                ❌ <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% session.removeAttribute("failedMsg"); } %>
        <% if (succMsg != null) { %>
            <div class="alert alert-success alert-dismissible fade show text-center fw-bold" role="alert">
                ✅ <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% session.removeAttribute("succMsg"); } %>
    </div>

    <!-- ✅ Fixed & Dynamic Explore Categories Buttons Section -->
    <div class="bg-white py-3 shadow-sm mb-4">
        <div class="container text-center">
            <h6 class="fw-bold text-muted text-uppercase small mb-2">🏷️ Explore Products By Category</h6>
            <div class="d-flex flex-wrap justify-content-center gap-2">
                <!-- 1. All Products -->
                <a href="index.jsp?category=all<%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                   class="btn <%= "all".equalsIgnoreCase(selectedCategory) ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                    🛍️ All Products
                </a>

                <!-- 2. Mobiles -->
                <a href="index.jsp?category=Mobiles<%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                   class="btn <%= "Mobiles".equalsIgnoreCase(selectedCategory) ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                    📱 Mobiles
                </a>

                <!-- 3. Electronics -->
                <a href="index.jsp?category=Electronics<%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                   class="btn <%= "Electronics".equalsIgnoreCase(selectedCategory) ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                    💻 Electronics
                </a>

                <!-- 4. Fashion -->
                <a href="index.jsp?category=Fashion<%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                   class="btn <%= "Fashion".equalsIgnoreCase(selectedCategory) ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                    👕 Fashion
                </a>

                <!-- 5. Books -->
                <a href="index.jsp?category=Books<%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                   class="btn <%= "Books".equalsIgnoreCase(selectedCategory) ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                    📚 Books
                </a>

                <!-- Additional Dynamic Categories from Database (if any new category exists) -->
                <% 
                    List<String> defaultCats = Arrays.asList("Mobiles", "Electronics", "Fashion", "Books");
                    if (dbCategories != null) {
                        for (String cat : dbCategories) {
                            if (!defaultCats.contains(cat)) {
                                boolean isSelected = cat.equalsIgnoreCase(selectedCategory);
                %>
                    <a href="index.jsp?category=<%= cat %><%= (searchQuery != null && !searchQuery.isEmpty()) ? "&search=" + searchQuery : "" %>" 
                       class="btn <%= isSelected ? "btn-primary" : "btn-outline-primary" %> fw-bold rounded-pill px-3 py-2">
                        📦 <%= cat %>
                    </a>
                <% 
                            }
                        }
                    }
                %>
            </div>
        </div>
    </div>

    <!-- Filter & Sort Toolbar -->
    <div class="container mb-4">
        <div class="card shadow-sm border-0 rounded-3 p-3 bg-white">
            <form action="index.jsp" method="get" class="row g-2 align-items-center">
                <input type="hidden" name="category" value="<%= selectedCategory %>">
                <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <input type="hidden" name="search" value="<%= searchQuery %>">
                <% } %>

                <div class="col-md-4">
                    <span class="fw-bold text-dark">
                        <% if (searchQuery != null && !searchQuery.trim().isEmpty()) { %>
                            🔍 Results for: <span class="text-primary">"<%= searchQuery %>"</span>
                        <% } else { %>
                            📦 Category: <span class="text-primary"><%= "all".equalsIgnoreCase(selectedCategory) ? "All Products" : selectedCategory %></span>
                        <% } %>
                        <span class="badge bg-secondary ms-1"><%= productList != null ? productList.size() : 0 %></span>
                    </span>
                </div>

                <div class="col-md-3 col-6">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light fw-bold">Max ₹</span>
                        <input type="number" name="maxPrice" class="form-control" placeholder="Price" 
                               value="<%= maxPrice != null ? maxPrice.intValue() : "" %>" min="1" step="50">
                    </div>
                </div>

                <div class="col-md-3 col-6">
                    <select name="sort" class="form-select form-select-sm">
                        <option value="newest" <%= "newest".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Newest First</option>
                        <option value="price_asc" <%= "price_asc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Price: Low to High</option>
                        <option value="price_desc" <%= "price_desc".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Price: High to Low</option>
                    </select>
                </div>

                <div class="col-md-2 col-12 d-flex gap-2">
                    <button type="submit" class="btn btn-primary btn-sm fw-bold w-100">Apply Filter</button>
                    <% if (searchQuery != null || !"all".equalsIgnoreCase(selectedCategory) || maxPrice != null || sortBy != null) { %>
                        <a href="index.jsp" class="btn btn-outline-danger btn-sm" title="Clear Filters">✕</a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- Main Content: Products Grid -->
    <div class="container mb-5">
        <div class="row g-4">
            <%
                if (productList != null && !productList.isEmpty()) {
                    for (Product p : productList) {
                        String desc = (p.getDescription() != null) ? p.getDescription() : "";
                        String shortDesc = desc.length() > 60 ? desc.substring(0, 60) + "..." : desc;
                        String imgName = (p.getImageName() != null && !p.getImageName().trim().isEmpty()) ? p.getImageName() : "default.png";
                        boolean isOutOfStock = (p.getStock() <= 0);
            %>
                <!-- Single Product Card -->
                <div class="col-xl-3 col-lg-4 col-md-6 col-sm-6">
                    <div class="card h-100 product-card shadow-sm border-0 rounded-3 overflow-hidden d-flex flex-column">
                        
                        <!-- Product Image -->
                        <div class="product-img-container">
                            <a href="productDetails.jsp?pid=<%= p.getProductId() %>" class="w-100 h-100 d-flex align-items-center justify-content-center">
                                <img src="uploads/<%= imgName %>" 
                                     class="product-img" 
                                     alt="<%= p.getName() %>"
                                     onerror="this.onerror=null; this.src='img/<%= imgName %>'; this.onerror=function(){this.src='https://via.placeholder.com/220x200?text=No+Image';};">
                            </a>
                        </div>

                        <!-- Card Body -->
                        <div class="card-body d-flex flex-column bg-white border-top p-3 flex-grow-1">
                            <div>
                                <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle mb-2">
                                    <%= p.getCategory() != null ? p.getCategory() : "General" %>
                                </span>
                                <h5 class="card-title fw-bold text-truncate mb-1" title="<%= p.getName() %>">
                                    <a href="productDetails.jsp?pid=<%= p.getProductId() %>" class="text-decoration-none text-dark">
                                        <%= p.getName() %>
                                    </a>
                                </h5>
                                <p class="card-text text-muted small mb-3">
                                    <%= !shortDesc.isEmpty() ? shortDesc : "Quality product at an affordable price." %>
                                </p>
                            </div>

                            <div class="mt-auto pt-2 border-top d-flex justify-content-between align-items-center">
                                <h4 class="fw-bold text-success mb-0">₹<%= p.getPrice() %></h4>
                                <span class="badge <%= isOutOfStock ? "bg-danger" : "bg-success" %>">
                                    <%= isOutOfStock ? "Out of Stock" : "In Stock" %>
                                </span>
                            </div>
                        </div>

                        <!-- Card Footer -->
                        <div class="card-footer bg-white border-0 pb-3 px-3">
                            <a href="AddToCartServlet?pid=<%= p.getProductId() %>" 
                               class="btn btn-primary w-100 fw-bold <%= isOutOfStock ? "disabled" : "" %>">
                                🛒 Add to Cart
                            </a>
                        </div>

                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <div class="col-12 text-center py-5">
                    <div class="p-5 bg-white rounded-4 shadow-sm border">
                        <h2 class="mb-3">📦</h2>
                        <h4 class="text-muted fw-bold">No matching products found!</h4>
                        <p class="text-muted mb-4">Try searching with another term, clearing price filters, or exploring all categories.</p>
                        <a href="index.jsp" class="btn btn-primary fw-bold px-4">View All Products</a>
                    </div>
                </div>
            <%
                }
            %>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>