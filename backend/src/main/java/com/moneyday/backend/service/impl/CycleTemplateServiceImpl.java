package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.FixedItem;
import com.moneyday.backend.mapper.CycleRecordMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.service.CycleTemplateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class CycleTemplateServiceImpl implements CycleTemplateService {

    @Autowired
    private CycleTemplateMapper mapper;

    @Autowired
    private CycleRecordMapper cycleRecordMapper;

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
        
        // 给新建的 items 设置 UUID
        if (template.getFixedItems() != null) {
            for (FixedItem item : template.getFixedItems()) {
                if (item.getId() == null || item.getId().isEmpty()) {
                    item.setId(UUID.randomUUID().toString());
                }
            }
        }
        
        mapper.insert(template);
        if (template.getIsDefault() == 1) {
            updateCurrentAndFutureCycles(template.getFixedItems());
        }
        return template;
    }

    private void updateCurrentAndFutureCycles(List<FixedItem> newTemplateItems) {
        if (newTemplateItems == null) newTemplateItems = new ArrayList<>();
        
        QueryWrapper<CycleRecord> query = new QueryWrapper<>();
        query.ge("cycle_end_date", LocalDate.now());
        List<CycleRecord> records = cycleRecordMapper.selectList(query);
        
        for (CycleRecord record : records) {
            List<FixedItem> currentItems = record.getFixedItems();
            if (currentItems == null) currentItems = new ArrayList<>();
            
            List<FixedItem> mergedItems = new ArrayList<>();
            for (FixedItem tplItem : newTemplateItems) {
                FixedItem newItem = new FixedItem();
                newItem.setId(tplItem.getId());
                newItem.setName(tplItem.getName());
                newItem.setType(tplItem.getType());
                newItem.setAmount(tplItem.getAmount());
                
                // 寻找旧状态
                boolean foundBooked = false;
                for (FixedItem oldItem : currentItems) {
                    boolean matchById = oldItem.getId() != null && oldItem.getId().equals(tplItem.getId());
                    boolean matchByName = oldItem.getName() != null && oldItem.getName().equals(tplItem.getName()) && 
                                          oldItem.getType() != null && oldItem.getType().equals(tplItem.getType());
                    
                    if (matchById || matchByName) {
                        if (Boolean.TRUE.equals(oldItem.getIsBooked())) {
                            foundBooked = true;
                            // 如果已经入账了，保留老金额
                            newItem.setAmount(oldItem.getAmount());
                        }
                        break;
                    }
                }
                newItem.setIsBooked(foundBooked);
                mergedItems.add(newItem);
            }
            
            record.setFixedItems(mergedItems);
            cycleRecordMapper.updateById(record);
        }
    }

    @Transactional
    public CycleTemplate update(CycleTemplate template) {
        if (template.getIsDefault() != null && template.getIsDefault() == 1) {
            mapper.clearDefault();
        } else {
            template.setIsDefault(0);
        }
        
        if (template.getFixedItems() != null) {
            for (FixedItem item : template.getFixedItems()) {
                if (item.getId() == null || item.getId().isEmpty()) {
                    item.setId(UUID.randomUUID().toString());
                }
            }
        }
        
        mapper.updateById(template);
        if (template.getIsDefault() == 1) {
            updateCurrentAndFutureCycles(template.getFixedItems());
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
            updateCurrentAndFutureCycles(template.getFixedItems());
        }
    }
}
