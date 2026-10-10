package com.moneyday.backend.service;

import com.moneyday.backend.entity.Category;
import com.moneyday.backend.mapper.CategoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    public List<Category> getAllCategories() {
        return categoryMapper.findAll();
    }

    public Category getCategoryById(Long id) {
        return categoryMapper.findById(id);
    }

    public Category addCategory(Category category) {
        categoryMapper.insert(category);
        return category;
    }

    public Category updateCategory(Category category) {
        categoryMapper.update(category);
        return category;
    }

    public void deleteCategory(Long id) {
        // According to PRD, we just soft delete or hard delete if not in use.
        // For MVP, we allow hard delete or update isActive=0
        categoryMapper.deleteById(id);
    }
}
