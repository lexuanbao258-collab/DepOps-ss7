package com.example.quickbite.cart.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CartController {

    @GetMapping("/")
    public String status() {
        return "Cart Service is running!";
    }
}
