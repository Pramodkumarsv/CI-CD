import static org.junit.Assert.*;
import org.junit.Test;

public class demoTest {
    @Test
    public void testAddition() {
        int a = 5;
        int b = 10;
        int sum = a + b;
        assertEquals(15, sum);
    }
}
