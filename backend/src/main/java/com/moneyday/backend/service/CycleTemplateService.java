package com.moneyday.backend.service;

import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

public interface CycleTemplateService {
    List<CycleTemplate> getAll();
    CycleTemplate add(CycleTemplate template);
    CycleTemplate update(CycleTemplate template);
    void delete(Long id);
    void setDefault(Long id);
}
