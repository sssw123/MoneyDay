package com.moneyday.backend.entity;

import java.math.BigDecimal;

public class WishlistVO extends Wishlist {
    /**
     * 结余达成进度百分比 (0-100)
     */
    private Integer progress;

    /**
     * 预计实现时间 (如 "2026-11-09", "当前可实现", "无法预估")
     */
    private String estimatedCompletionDate;

    /**
     * 是否触发超支保底推算
     */
    private Boolean isEstimatedFallback;

    /**
     * 推算原因/说明
     */
    private String estimatedReason;

    /**
     * 当前累计结余
     */
    private BigDecimal availableFunds;

    /**
     * 结余缺口
     */
    private BigDecimal gap;

    public Integer getProgress() { return progress; }
    public void setProgress(Integer progress) { this.progress = progress; }

    public String getEstimatedCompletionDate() { return estimatedCompletionDate; }
    public void setEstimatedCompletionDate(String estimatedCompletionDate) { this.estimatedCompletionDate = estimatedCompletionDate; }

    public Boolean getIsEstimatedFallback() { return isEstimatedFallback; }
    public void setIsEstimatedFallback(Boolean isEstimatedFallback) { this.isEstimatedFallback = isEstimatedFallback; }

    public String getEstimatedReason() { return estimatedReason; }
    public void setEstimatedReason(String estimatedReason) { this.estimatedReason = estimatedReason; }

    public BigDecimal getAvailableFunds() { return availableFunds; }
    public void setAvailableFunds(BigDecimal availableFunds) { this.availableFunds = availableFunds; }

    public BigDecimal getGap() { return gap; }
    public void setGap(BigDecimal gap) { this.gap = gap; }
}
