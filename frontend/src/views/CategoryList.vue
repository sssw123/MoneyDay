<template>
  <div>
    <div style="margin-bottom: 16px;">
      <a-button type="primary" @click="showModal">新增分类</a-button>
    </div>
    
    <a-table :dataSource="categories" :columns="columns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'">
          <a-tag :color="record.type === 1 ? 'green' : 'red'">
            {{ record.type === 1 ? '收入' : '支出' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'isActive'">
          <a-switch :checked="record.isActive === 1" @change="(val) => toggleActive(record, val)" />
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a @click="editCategory(record)">编辑</a>
            <a-popconfirm title="确定删除吗？" @confirm="deleteCategory(record.id)">
              <a style="color: red">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="visible" :title="editingId ? '编辑分类' : '新增分类'" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="分类名称" required>
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="类型" required>
          <a-radio-group v-model:value="formState.type">
            <a-radio :value="1">收入</a-radio>
            <a-radio :value="2">支出</a-radio>
          </a-radio-group>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const categories = ref([]);
const visible = ref(false);
const editingId = ref<number | null>(null);

const formState = ref({
  name: '',
  type: 2,
  isActive: 1
});

const columns = [
  { title: '分类名称', dataIndex: 'name', key: 'name' },
  { title: '类型', key: 'type' },
  { title: '启用状态', key: 'isActive' },
  { title: '操作', key: 'action' }
];

const fetchCategories = async () => {
  categories.value = await request.get('/categories');
};

const showModal = () => {
  editingId.value = null;
  formState.value = { name: '', type: 2, isActive: 1 };
  visible.value = true;
};

const editCategory = (record: any) => {
  editingId.value = record.id;
  formState.value = { ...record };
  visible.value = true;
};

const toggleActive = async (record: any, val: boolean) => {
  try {
    const updated = { ...record, isActive: val ? 1 : 0 };
    await request.put(`/categories/${record.id}`, updated);
    message.success('状态已更新');
    fetchCategories();
  } catch (e) {
  }
};

const handleOk = async () => {
  try {
    if (editingId.value) {
      await request.put(`/categories/${editingId.value}`, formState.value);
      message.success('更新成功');
    } else {
      await request.post('/categories', formState.value);
      message.success('添加成功');
    }
    visible.value = false;
    fetchCategories();
  } catch (e) {
  }
};

const deleteCategory = async (id: number) => {
  try {
    await request.delete(`/categories/${id}`);
    message.success('删除成功');
    fetchCategories();
  } catch (e) {
  }
};

onMounted(() => {
  fetchCategories();
});
</script>
