<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Login - E-Shop</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-5 col-lg-4">
                <div class="card shadow-lg border-0 rounded-3">
                    <div class="card-header bg-success text-white text-center py-3">
                        <h4 class="mb-0 fw-bold">Login to E-Shop</h4>
                    </div>
                    <div class="card-body p-4">

                        <%-- Alert Messages (Success / Error) --%>
                        <% 
                            String errorMsg = (String) session.getAttribute("failedMsg");
                            String succMsg = (String) session.getAttribute("succMsg");
                            if (errorMsg != null) { 
                        %>
                            <div class="alert alert-danger text-center" role="alert"><%= errorMsg %></div>
                        <% 
                                session.removeAttribute("failedMsg");
                            } 
                            if (succMsg != null) { 
                        %>
                            <div class="alert alert-success text-center" role="alert"><%= succMsg %></div>
                        <% 
                                session.removeAttribute("succMsg");
                            } 
                        %>

                        <!-- Login Form -->
                        <form action="LoginServlet" method="post">
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <input type="email" class="form-control" id="email" name="email" placeholder="Enter your registered email" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password" placeholder="Enter password" required>
                            </div>

                            <button type="submit" class="btn btn-success w-100 py-2 mt-2 fw-bold">Login</button>
                        </form>

                    </div>
                    <div class="card-footer text-center py-3 bg-white">
                        <small>Don't have an account? <a href="register.jsp" class="text-decoration-none fw-bold">Register Here</a></small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>