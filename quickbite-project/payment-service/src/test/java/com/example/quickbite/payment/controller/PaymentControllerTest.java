package com.example.quickbite.payment.controller;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class PaymentControllerTest {

    @Test
    void returnsServiceStatus() {
        PaymentController controller = new PaymentController();

        assertEquals("Payment Service is running!", controller.status());
    }
}
