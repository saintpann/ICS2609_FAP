package tools;

import java.io.UnsupportedEncodingException;
import java.util.Base64;
import javax.crypto.Cipher;

import javax.crypto.spec.SecretKeySpec;


public class Cryptograph {
    private String algo;
    private String mode;
    private String padding;
    private byte[] keyBytes;
    
    public Cryptograph(String secretKey, String algo, String mode, String padding){
        this.algo=algo;
        this.mode=mode;
        this.padding=padding;
        try {
            keyBytes = secretKey.getBytes("UTF-8");
        } catch (UnsupportedEncodingException ex) {
            System.out.println("Error Getting keyBytes");
            ex.printStackTrace();
        }
    }
    
    public String encrypt(String toEncrypt){
        String encryptedStr = null;
        try{
            Cipher cipher = Cipher.getInstance(this.algo+"/"+this.mode+"/"+this.padding);
            final SecretKeySpec secretKey = new SecretKeySpec(this.keyBytes,this.algo);
            cipher.init(Cipher.ENCRYPT_MODE,secretKey);
            byte[] encryptedBytes = cipher.doFinal(toEncrypt.getBytes("UTF-8"));
            encryptedStr = Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            System.out.println("Encryption Error");
            e.printStackTrace();
        } 
        return encryptedStr;
    }
    
    public String decrypt(String toDecrypt){
        String decryptedStr = null;
        if (toDecrypt == null || toDecrypt.trim().isEmpty()) {
            System.out.println("Warning: Attempted to decrypt a null or empty password.");
            return ""; // Return empty string so the .equals() check in the Servlet just fails normally
        }
        try{
            Cipher cipher = Cipher.getInstance(this.algo+"/"+this.mode+"/"+this.padding);
            final SecretKeySpec secretKey = new SecretKeySpec(this.keyBytes,this.algo);
            cipher.init(Cipher.DECRYPT_MODE,secretKey);
            byte[] decodedBytes = Base64.getDecoder().decode(toDecrypt);
            byte[] decryptedBytes = cipher.doFinal(decodedBytes);
            decryptedStr = new String(decryptedBytes, "UTF-8");
            
        } catch (Exception e) {
            System.out.println("Decryption Error");
            e.printStackTrace();
        } 
        return decryptedStr;
    }
}
