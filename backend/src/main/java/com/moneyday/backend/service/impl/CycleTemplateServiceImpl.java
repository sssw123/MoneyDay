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
        if (template.getIsDefault() == 1) {
            updateCurrentAndFutureCycles(template.getDefaultFixedDeposit(), template.getDefaultFixedIncome());
        }
        return template;
    }

    @Autowired
    private com.moneyday.backend.mapper.CycleRecordMapper cycleRecordMapper;

    private void updateCurrentAndFutureCycles(java.math.BigDecimal newFixedDeposit, java.math.BigDecimal newFixedIncome) {
        com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<com.moneyday.backend.entity.CycleRecord> updateWrapper =
            new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<>();
        updateWrapper.ge("cycle_end_date", java.time.LocalDate.now());
        if (newFixedDeposit != null) updateWrapper.set("fixed_deposit", newFixedDeposit);
        if (newFixedIncome != null) updateWrapper.set("fixed_income", newFixedIncome);
        if (newFixedDeposit != null || newFixedIncome != null) {
            cycleRecordMapper.update(null, updateWrapper);
        }
    }

    @Transactional
    public CycleTemplate update(CycleTemplate template) {
        if (template.getIsDefault() != null && template.getIsDefault() == 1) {
            mapper.clearDefault();
        } else {
            template.setIsDefault(0);
        }
        mapper.updateById(template);
        if (template.getIsDefault() == 1) {
            updateCurrentAndFutureCycles(template.getDefaultFixedDeposit(), template.getDefaultFixedIncome());
        }
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
        CycleTemplate template = mapper.selectById(id);
        if (template != null) {
            updateCurrentAndFutureCycles(template.getDefaultFixedDeposit(), template.getDefaultFixedIncome());
        }
    }
}
