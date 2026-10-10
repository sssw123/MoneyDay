package com.moneyday.backend.service;

import com.moneyday.backend.entity.Target;
import com.moneyday.backend.mapper.TargetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TargetService {

    @Autowired
    private TargetMapper targetMapper;

    public List<Target> getAllTargets() {
        return targetMapper.findAll();
    }

    public Target addTarget(Target target) {
        targetMapper.insert(target);
        return target;
    }

    public Target updateTarget(Target target) {
        targetMapper.update(target);
        return target;
    }

    public void deleteTarget(Long id) {
        targetMapper.deleteById(id);
    }
}
