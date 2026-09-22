<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ecommerce.model.User" %>
<%@ page import="com.ecommerce.model.Cart" %>
<%@ page import="com.ecommerce.model.Product" %>
<%@ page import="com.ecommerce.dao.CartDAO" %>
<%@ page import="com.ecommerce.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .cart-thumb {
            width: 65px;
            height: 65px;
            object-fit: contain;
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 4px;
            border: 1px solid #dee2e6;
        }
        .qty-btn {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            font-weight: bold;
        }
    </style>
</head>
<body class="bg-light">

    <%-- Session Verification & Cart Data Extraction --%>
    <%
        User user = (User) session.getAttribute("userobj");
        if (user == null) {
            session.setAttribute("failedMsg", "Please login to view your shopping cart!");
            response.sendRedirect("login.jsp");
            return;
        }

        CartDAO cartDao = new CartDAO();
        List<Cart> cartList = cartDao.getCartByUserId(user.getUserId());
        int cartCount = (cartList != null) ? cartList.size() : 0;

        ProductDAO productDao = new ProductDAO();

        double subTotal = 0.0;
        boolean hasOutOfStockItem = false;
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
                            👤 Welcome, <%= user.getName() %>
                            <% if ("admin".equalsIgnoreCase(user.getRole())) { %>
                                <span class="badge bg-danger ms-1">Admin</span>
                            <% } %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 rounded-3 mt-2">
                            <li><a class="dropdown-item fw-semibold py-2" href="profile.jsp">👤 My Profile & Security</a></li>
                            <li><a class="dropdown-item fw-semibold py-2" href="myOrders.jsp">📦 My Orders</a></li>
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
                ✅ <%= succMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% session.removeAttribute("succMsg"); } %>
    </div>

    <!-- Main Content: Cart List -->
    <div class="container my-4 mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold text-primary mb-0">🛒 Your Shopping Cart</h3>
                <small class="text-muted">Review items before proceeding to checkout</small>
            </div>
            <a href="index.jsp" class="btn btn-outline-primary fw-bold">← Continue Shopping</a>
        </div>

        <% if (cartList != null && !cartList.isEmpty()) { %>
        <div class="row g-4">
            
            <!-- Left Side: Cart Items Table -->
            <div class="col-lg-8">
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold text-dark mb-0">Items in Cart (<%= cartCount %>)</h5>
                        <small class="text-muted">Stock availability verified live</small>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th class="ps-3">Product</th>
                                        <th class="text-center">Price</th>
                                        <th class="text-center" style="min-width: 140px;">Quantity</th>
                                        <th class="text-center">Total</th>
                                        <th class="text-center">Availability</th>
                                        <th class="text-center pe-3">Remove</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (Cart c : cartList) {
                                            Product prod = productDao.getProductById(c.getProductId());
                                            
                                            String pName = (c.getProductName() != null && !c.getProductName().trim().isEmpty()) 
                                                           ? c.getProductName() 
                                                           : (prod != null ? prod.getName() : "Product Item");

                                            String img = (prod != null && prod.getImageName() != null && !prod.getImageName().trim().isEmpty()) 
                                                         ? prod.getImageName().trim() 
                                                         : "default.png";

                                            int availableStock = (prod != null) ? prod.getStock() : 0;
                                            boolean isOutOfStock = (availableStock <= 0 || availableStock < c.getQuantity());

                                            if (isOutOfStock) {
                                                hasOutOfStockItem = true;
                                            }

                                            double itemTotal = (c.getTotalPrice() > 0) ? c.getTotalPrice() : (c.getPrice() * c.getQuantity());
                                            subTotal += itemTotal;
                                    %>
                                    <tr class="<%= isOutOfStock ? "table-danger-subtle" : "" %>">
                                        <!-- Product Image + Name -->
                                        <td class="ps-3">
                                            <div class="d-flex align-items-center gap-3">
                                                <img src="uploads/<%= img %>" 
                                                     alt="<%= pName %>" 
                                                     class="cart-thumb"
                                                     onerror="this.onerror=null; this.src='img/<%= img %>'; this.onerror=function(){this.src='https://via.placeholder.com/65?text=No+Img';};">
                                                <div>
                                                    <a href="productDetails.jsp?pid=<%= c.getProductId() %>" class="fw-bold text-dark text-decoration-none">
                                                        <%= pName %>
                                                    </a>
                                                    <small class="text-muted d-block">ID: #<%= c.getProductId() %></small>
                                                </div>
                                            </div>
                                        </td>

                                        <!-- Unit Price -->
                                        <td class="text-center fw-semibold text-muted">
                                            ₹<%= String.format("%.2f", c.getPrice()) %>
                                        </td>

                                        <!-- Quantity Controls -->
                                        <td class="text-center">
                                            <div class="d-inline-flex align-items-center border rounded-pill p-1 bg-white shadow-sm">
                                                <!-- Decrease Qty -->
                                                <a href="UpdateCartServlet?cartId=<%= c.getCartId() %>&action=dec" 
                                                   class="btn btn-sm btn-light rounded-circle qty-btn text-dark <%= c.getQuantity() <= 1 ? "disabled" : "" %>">
                                                    -
                                                </a>
                                                
                                                <span class="px-3 fw-bold fs-6"><%= c.getQuantity() %></span>

                                                <!-- Increase Qty -->
                                                <a href="UpdateCartServlet?cartId=<%= c.getCartId() %>&action=inc" 
                                                   class="btn btn-sm btn-light rounded-circle qty-btn text-dark <%= (prod != null && c.getQuantity() >= prod.getStock()) ? "disabled" : "" %>">
                                                    +
                                                </a>
                                            </div>
                                        </td>

                                        <!-- Item Total -->
                                        <td class="text-center fw-bold text-success fs-6">
                                            ₹<%= String.format("%.2f", itemTotal) %>
                                        </td>

                                        <!-- Stock Status Badge -->
                                        <td class="text-center">
                                            <% if (availableStock <= 0) { %>
                                                <span class="badge bg-danger px-2 py-1">Out of Stock</span>
                                            <% } else if (availableStock < c.getQuantity()) { %>
                                                <span class="badge bg-warning text-dark px-2 py-1">Only <%= availableStock %> left</span>
                                            <% } else { %>
                                                <span class="badge bg-success px-2 py-1">Available (<%= availableStock %>)</span>
                                            <% } %>
                                        </td>

                                        <!-- Remove Action Button -->
                                        <td class="text-center pe-3">
                                            <a href="RemoveCartServlet?cartId=<%= c.getCartId() %>" 
                                               class="btn btn-outline-danger btn-sm rounded-circle qty-btn" 
                                               title="Remove Item"
                                               onclick="return confirm('Remove <%= pName %> from cart?');">
                                                🗑️
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <% if (hasOutOfStockItem) { %>
                    <div class="alert alert-warning border-warning d-flex align-items-center gap-2 mt-3 rounded-3" role="alert">
                        <span class="fs-4">⚠️</span>
                        <div>
                            <strong>Attention:</strong> Some items in your cart are currently <strong>Out of Stock</strong> or exceed available warehouse quantity. Please remove or adjust them to enable checkout.
                        </div>
                    </div>
                <% } %>
            </div>

            <!-- Right Side: Order Summary & Checkout Card -->
            <div class="col-lg-4">
                <div class="card shadow-sm border-0 rounded-4 p-4 bg-white sticky-top" style="top: 90px;">
                    <h5 class="fw-bold text-dark border-bottom pb-3 mb-3">🧾 Price Details</h5>

                    <ul class="list-group list-group-flush mb-3">
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                            <span class="text-muted">Total MRP Items:</span>
                            <span class="fw-semibold"><%= cartCount %></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                            <span class="text-muted">Cart Subtotal:</span>
                            <span class="fw-semibold text-dark">₹<%= String.format("%.2f", subTotal) %></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                            <span class="text-muted">Delivery Charges:</span>
                            <span class="text-success fw-bold">FREE</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-0 px-0 py-2">
                            <span class="text-muted">Promo Code Discount:</span>
                            <small class="text-muted">Applied at Checkout</small>
                        </li>
                        <li class="list-group-item d-flex justify-content-between border-top px-0 pt-3 pb-2 fs-5 fw-bold text-dark">
                            <span>Estimated Total:</span>
                            <span class="text-success">₹<%= String.format("%.2f", subTotal) %></span>
                        </li>
                    </ul>

                    <!-- Checkout Button with Out-of-Stock Lock -->
                    <div class="d-grid gap-2">
                        <% if (hasOutOfStockItem) { %>
                            <button type="button" class="btn btn-secondary btn-lg fw-bold py-3 shadow-sm" disabled>
                                🔒 Checkout Disabled (Stock Issue)
                            </button>
                        <% } else { %>
                            <a href="checkout.jsp" class="btn btn-success btn-lg fw-bold py-3 shadow-sm">
                                🚀 Proceed to Checkout
                            </a>
                        <% } %>

                        <a href="index.jsp" class="btn btn-outline-secondary fw-semibold py-2">
                            Continue Browsing
                        </a>
                    </div>

                    <div class="mt-4 pt-3 border-top text-center">
                        <small class="text-muted d-block">🔒 Safe & Secure Checkout</small>
                        <small class="text-muted d-block">COD • UPI • Card Payments Available</small>
                    </div>
                </div>
            </div>

        </div>
        <% } else { %>
            <!-- Empty Cart State -->
            <div class="card shadow-sm border-0 rounded-4 text-center py-5 bg-white">
                <div class="card-body py-5">
                    <div class="display-1 mb-3">🛒</div>
                    <h3 class="fw-bold text-dark mb-2">Your Cart is Empty!</h3>
                    <p class="text-muted mb-4">Explore our catalog and find the best deals today.</p>
                    <a href="index.jsp" class="btn btn-primary btn-lg fw-bold px-5 rounded-pill shadow-sm">
                        🛍️ Start Shopping Now
                    </a>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>