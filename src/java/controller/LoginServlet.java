/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import tools.CertDAO;
import tools.ExamDAO;
import tools.UserDAO;

/**
 *
 * @author Saintan
 */
public class LoginServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        CertDAO c = new CertDAO();
        UserDAO b = new UserDAO();
        ExamDAO a = new ExamDAO();
        if (c.testConnection()){
            System.out.println("cert works = MySQL");
        }
        if (b.testConnection())
        {
            System.out.println("User works = Derby");
        }
        if (a.testConnection()){
            System.out.println("exam works = postgre");
        }
        response.sendRedirect(request.getContextPath() + "/app/success.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
