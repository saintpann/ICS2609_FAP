<%@page contentType="text/html" pageEncoding="UTF-8"%>
    <form action ="${pageContext.request.contextPath}">
        <button class = "submit-btn" type="submit">return</button>  
    </form>
    </div>
    </main>
    <footer class="pill-footer">
        <jsp:include page="<%= (String)application.getAttribute("footer") %>" />
    </footer>
    </body>
</html>
