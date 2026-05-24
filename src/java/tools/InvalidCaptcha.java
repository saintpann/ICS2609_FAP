
package tools;
import javax.servlet.ServletException;

public class InvalidCaptcha extends ServletException{
    public InvalidCaptcha(String message){
        super(message);
    }
}
