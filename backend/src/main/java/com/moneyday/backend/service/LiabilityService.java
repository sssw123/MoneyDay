package com.moneyday.backend.service;

import com.moneyday.backend.entity.Liability;
import com.moneyday.backend.entity.LiabilityVO;
import java.math.BigDecimal;
import java.util.List;

public interface LiabilityService {
    List<LiabilityVO> getAllLiabilities();
    Liability addLiability(Liability liability);
    Liability updateLiability(Liability liability);
    void deleteLiability(Long id);
    void settleLiability(Long id, Long accountId, BigDecimal settleAmount);
    void checkAndExecuteDueRepayments();
}
