package com.moneyday.backend.entity;

import java.math.BigDecimal;

public class LiabilityVO extends Liability {
    private Integer remainingPeriods;
    private BigDecimal remainingAmount;
    private Integer progressPercent;
    private String defaultAccountName;
    private String categoryName;

    public Integer getRemainingPeriods() { return remainingPeriods; }
    public void setRemainingPeriods(Integer remainingPeriods) { this.remainingPeriods = remainingPeriods; }

    public BigDecimal getRemainingAmount() { return remainingAmount; }
    public void setRemainingAmount(BigDecimal remainingAmount) { this.remainingAmount = remainingAmount; }

    public Integer getProgressPercent() { return progressPercent; }
    public void setProgressPercent(Integer progressPercent) { this.progressPercent = progressPercent; }

    public String getDefaultAccountName() { return defaultAccountName; }
    public void setDefaultAccountName(String defaultAccountName) { this.defaultAccountName = defaultAccountName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}
