package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.CategoryService;

import com.moneyday.backend.entity.Category;
import com.moneyday.backend.mapper.CategoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryServiceImpl implements CategoryService {
    @Autowired private com.moneyday.backend.security.OwnershipGuard guard;


    @Autowired
    private CategoryMapper categoryMapper;

    public List<Category> getAllCategories() {
        return categoryMapper.selectList(null);
    }

    public Category getCategoryById(Long id) {
        return guard.require(categoryMapper,id);
    }

    public Category addCategory(Category category) {
        category.setId(null);
        categoryMapper.insert(category);
        return category;
    }

    public Category updateCategory(Category category) {
        guard.require(categoryMapper,category.getId());
        categoryMapper.updateById(category);
        return category;
    }

    public void deleteCategory(Long id) {
        // According to PRD, we just soft delete or hard delete if not in use.
        // For MVP, we allow hard delete or update isActive=0
        guard.require(categoryMapper,id);
        categoryMapper.deleteById(id);
    }
}
