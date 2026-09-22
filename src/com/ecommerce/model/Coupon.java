package com.ecommerce.model;

public class Coupon {
    private int couponId;
    private String couponCode;
    private String discountType; // "PERCENT" or "FLAT"
    private double discountValue;
    private double minOrderAmount;
    private String status;

    public Coupon() {}

    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }

    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public double getDiscountValue() { return discountValue; }
    public void setDiscountValue(double discountValue) { this.discountValue = discountValue; }

    public double getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(double minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}