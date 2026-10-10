package com.moneyday.backend.service;

import com.moneyday.backend.entity.Target;
import com.moneyday.backend.mapper.TargetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

public interface TargetService {
    List<Target> getAllTargets();
    Target addTarget(Target target);
    Target updateTarget(Target target);
    void deleteTarget(Long id);
    void realizeTarget(Long id, Long accountId);
}
