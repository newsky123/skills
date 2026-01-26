---
name: tr3
description: Technical solution documentation framework for creating comprehensive technical proposals (TR3 format). Use when creating or organizing technical solution documents that require: (1) Background and competitor analysis, (2) Solution architecture with module diagrams, (3) Performance, power, stability analysis, (4) Security and privacy assessment, (5) Multiple solution comparison and recommendations. Triggers on requests for "TR3", "technical solution", "方案文档", "技术方案", or structured technical proposals.
---

# TR3 Technical Solution Documentation

Generate comprehensive technical solution documents following the TR3 standardized format.

## Document Structure

Create documents with the following sections in order:

1. **背景介绍 (Background Introduction)**
   - Problem statement and context
   - Business requirements and objectives
   - Current state and pain points

2. **行业友商对比分析 (Industry Competitor Analysis)**
   - Competitor solutions overview
   - Feature comparison table
   - Strengths and weaknesses analysis

3. **方案概述 (Solution Overview)**
   - High-level solution description
   - Key features and capabilities
   - Value proposition

4. **整体方案 (Overall Solution)**
   - Architecture diagram (module-based)
   - Component descriptions
   - Technology stack
   - Integration points

5. **关键流程 (Key Processes)**
   - Critical workflows with sequence diagrams
   - Data flow descriptions
   - User interaction flows

6. **功耗影响分析 (Power Consumption Impact)**
   - Power consumption scenarios
   - Optimization strategies
   - Measurement methodology

7. **性能影响分析 (Performance Impact Analysis)**
   - Memory usage analysis
   - ROM storage requirements
   - CPU/processing overhead
   - Network bandwidth impact
   - Performance benchmarks

8. **稳定性分析 (Stability Analysis)**
   - Failure scenarios and handling
   - Error recovery mechanisms
   - Reliability metrics
   - Testing strategy

9. **安全隐私分析 (Security and Privacy Analysis)**
   - Personal data identification
   - Data handling procedures
   - Storage encryption requirements
   - Data retention policies
   - Deletion mechanisms
   - Compliance considerations

10. **方案对比 (Solution Comparison)** *(if multiple solutions)*
    - Comparison matrix
    - Trade-off analysis
    - Recommended solution
    - Recommendation rationale

## Detailed Guidelines

See [references/template.md](references/template.md) for detailed section templates and content guidelines.

## Output Format

Generate documents in Markdown format with:
- Clear section hierarchy (H1 for main sections, H2 for subsections)
- Tables for comparisons and data
- Mermaid diagrams for architecture and flows
- Bullet points for lists
- Code blocks for technical specifications
