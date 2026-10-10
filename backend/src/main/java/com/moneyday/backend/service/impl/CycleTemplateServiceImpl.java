package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.CycleTemplateService;

import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CycleTemplateServiceImpl implements CycleTemplateService {

    @Autowired
    private CycleTemplateMapper mapper;

    public List<CycleTemplate> getAll() {
        return mapper.selectList(null);
    }

    @Transactional
    public CycleTemplate add(CycleTemplate template) {
        if (template.getIsDefault() != null && template.getIsDefault() == 1) {
            mapper.clearDefault();
        } else {
            template.setIsDefault(0);
        }
        mapper.insert(template);
        return template;
    }

    @Transactional
    public CycleTemplate update(CycleTemplate template) {
        if (template.getIsDefault() != null && template.getIsDefault() == 1) {
            mapper.clearDefault();
        } else {
            template.setIsDefault(0);
        }
        mapper.updateById(template);
        return template;
    }

    @Transactional
    public void delete(Long id) {
        mapper.deleteById(id);
    }

    @Transactional
    public void setDefault(Long id) {
        mapper.clearDefault();
        mapper.setDefault(id);
    }
}
