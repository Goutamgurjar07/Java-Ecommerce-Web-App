package com.ecommerce.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Product;

@WebServlet("/SearchSuggestionsServlet")
public class SearchSuggestionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String query = req.getParameter("term");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        PrintWriter out = resp.getWriter();

        if (query == null || query.trim().isEmpty()) {
            out.print("[]");
            out.flush();
            return;
        }

        try {
            ProductDAO dao = new ProductDAO();
            List<Product> list = dao.searchProducts(query.trim());

            StringBuilder json = new StringBuilder();
            json.append("[");

            if (list != null) {
                int limit = Math.min(list.size(), 6);
                for (int i = 0; i < limit; i++) {
                    Product p = list.get(i);
                    String img = (p.getImageName() != null && !p.getImageName().trim().isEmpty()) ? p.getImageName().trim() : "default.png";

                    json.append("{");
                    json.append("\"id\":").append(p.getProductId()).append(",");
                    json.append("\"name\":").append(escapeJson(p.getName())).append(",");
                    json.append("\"category\":").append(escapeJson(p.getCategory())).append(",");
                    json.append("\"price\":").append(p.getPrice()).append(",");
                    json.append("\"image\":").append(escapeJson(img));
                    json.append("}");

                    if (i < limit - 1) {
                        json.append(",");
                    }
                }
            }

            json.append("]");
            out.print(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        } finally {
            out.flush();
        }
    }

    private String escapeJson(String val) {
        if (val == null) return "\"\"";
        return "\"" + val.replace("\\", "\\\\")
                         .replace("\"", "\\\"")
                         .replace("\n", " ")
                         .replace("\r", " ") + "\"";
    }
}