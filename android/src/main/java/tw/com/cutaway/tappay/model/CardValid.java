package tw.com.cutaway.tappay.model;

public class CardValid {

    private boolean pass;
    private String message;

    public CardValid(boolean pass, String message) {
        this.pass = pass;
        this.message = message;
    }

    public boolean isPass() {
        return pass;
    }

    public void setPass(boolean pass) {
        this.pass = pass;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
