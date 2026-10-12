package com.moneyday.backend.service;

import com.moneyday.backend.entity.Target;
import com.moneyday.backend.entity.TargetVO;
import java.util.List;

public interface TargetService {
    List<TargetVO> getAllTargets();
    Target addTarget(Target target);
    Target updateTarget(Target target);
    void deleteTarget(Long id);
    void realizeTarget(Long id, Long accountId);
    void unrealizeTarget(Long id);
}
