package com.moneyday.backend.security;

import com.moneyday.backend.entity.Category;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.mapper.CategoryMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import org.springframework.stereotype.Component;
import java.util.ArrayList;

@Component
public class PersonalDataSeeder {
    private final CategoryMapper categories;
    private final CycleTemplateMapper templates;
    public PersonalDataSeeder(CategoryMapper categories, CycleTemplateMapper templates) { this.categories=categories; this.templates=templates; }
    public void seed(long userId) {
        UserContext.call(userId, () -> {
            String[] names = {"工资", "理财收益", "餐饮", "交通", "购物", "房租", "分期还款", "目标"};
            for (int i=0;i<names.length;i++) {
                Category c = new Category(); c.setName(names[i]); c.setType(i<2?1:2); c.setIsActive(1); categories.insert(c);
            }
            CycleTemplate t = new CycleTemplate(); t.setName("自然月"); t.setStartDay(1); t.setIsDefault(1); t.setFixedItems(new ArrayList<>()); templates.insert(t);
            return null;
        });
    }
}
